//
//  OXMAdViewManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdViewManager.h"

#import "OXMAbstractCreative.h"
#import "OXMAdLoadManagerProtocol.h"
#import "OXMAutoRefreshManager.h"
#import "OXMCreativeModel.h"
#import "OXMEventManager.h"
#import "OXMFunctions+Private.h"
#import "OXMInterstitialLayoutConfigurator.h"
#import "OXMLog.h"
#import "OXMModalManager.h"
#import "OXMNSThreadProtocol.h"
#import "OXASDKConfiguration.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMTransaction.h"
#import "OXMVideoCreative.h"
#import "UIView+OxmExtensions.h"

#import "OXMMacros.h"

@interface OXMAdViewManager ()

@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;
@property (weak, nullable) OXMAbstractCreative *currentCreative;
@property (nonatomic, strong, nullable) OXMTransaction *externalTransaction;
@property (nonatomic, nullable, readonly) OXMTransaction *currentTransaction; // computed
@property (nonatomic, assign) BOOL videoInterstitialDidClose;

@end

@implementation OXMAdViewManager

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
              modalManagerDelegate:(nullable id<OXMModalManagerDelegate>)modalManagerDelegate
{
    if (!(self = [super init])) {
        return nil;
    }
        
    OXMAssert(connection);
    
    _autoDisplayOnLoad = YES;
    _serverConnection = connection;
    _modalManager = [[OXMModalManager alloc] initWithDelegate:modalManagerDelegate];
    _adConfiguration = [OXMAdConfiguration new];
    _videoInterstitialDidClose = NO;
    
    return self;
}

#pragma mark - API

- (NSString *)revenueForNextCreative {
    return [self.currentTransaction revenueForCreativeAfter:self.currentCreative];
}

- (BOOL)isAbleToShowCurrentCreative {
    if (!self.currentCreative) {
        OXMLogError(@"No creative to display");
        return NO;
    }
    
    if ([self isInterstitial] && ![self.adViewManagerDelegate viewControllerForModalPresentation]) {
        OXMLogError(@"viewControllerForModalPresentation returned nil");
        return NO;
    }
    
    return YES;
}

- (void)show {
    if (![self isAbleToShowCurrentCreative]) {
        return;
    }
    
    UIViewController* viewController = [self.adViewManagerDelegate viewControllerForModalPresentation];
    if (!viewController) {
        OXMLogError(@"viewControllerForModalPresentation is nil. Check the implementation of Ad View Delegate.");
        return;
    }
    
    self.currentCreative.creativeViewDelegate = self;
    
    if ([self isInterstitial]) {
        OXMInterstitialDisplayProperties* displayProperties = [self.adViewManagerDelegate interstitialDisplayProperties];
        
        //set interstitial display properties from ad configuration parameters
        [OXMInterstitialLayoutConfigurator configurePropertiesWithAdConfiguration:self.adConfiguration displayProperties:displayProperties];
        //we need to force orientation if device is not in the expected one
        if (displayProperties.interstitialLayout == OXMInterstitialLayoutLandscape) {
            [self.modalManager forceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else if (displayProperties.interstitialLayout == OXMInterstitialLayoutPortrait) {
            [self.modalManager forceOrientation:UIInterfaceOrientationPortrait];
        }
        [self.currentCreative showAsInterstitialFromRootViewController:viewController displayProperties:displayProperties];
    } else {
        UIView* creativeView = self.currentCreative.view;
        if (!creativeView) {
            OXMLogError(@"Creative has no view");
            return;
        }
        
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [[self.adViewManagerDelegate displayView] addSubview:creativeView];
            [self.currentCreative displayWithRootViewController:viewController];
        });
    }
}

- (void)pause {
    [self.currentCreative pause];
}

- (void)resume {
    [self.currentCreative resume];
}

- (void)mute {
    [self.currentCreative mute];
}

- (void)unmute {
    [self.currentCreative unmute];
}

- (BOOL)isMuted {
    return [self.currentCreative isMuted];
}

- (void)handleExternalTransaction:(OXMTransaction *)transaction {
    self.externalTransaction = transaction;
    [self onTransactionIsReady:transaction];
}

#pragma mark - OXMCreativeViewDelegate

- (void)videoCreativeDidComplete:(OXMAbstractCreative *)creative {
    if ([self.adViewManagerDelegate respondsToSelector:@selector(videoAdDidFinish)]) {
        [self.adViewManagerDelegate videoAdDidFinish];
    }
}

- (void)videoWasMuted:(OXMAbstractCreative *)creative {
    if ([self.adViewManagerDelegate respondsToSelector:@selector(videoAdWasMuted)]) {
        [self.adViewManagerDelegate videoAdWasMuted];
    }
}

- (void)videoWasUnmuted:(OXMAbstractCreative *)creative {
    if ([self.adViewManagerDelegate respondsToSelector:@selector(videoAdWasUnmuted)]) {
        [self.adViewManagerDelegate videoAdWasUnmuted];
    }
}

- (void)creativeDidComplete:(OXMAbstractCreative *)creative {
    OXMLogWhereAmI();
    
    if (!self.adConfiguration.isBuiltInVideo && self.currentCreative.view && self.currentCreative.view.superview) {
        [self.currentCreative.view removeFromSuperview];
    }
    
    //When a creative completes, show the next one in the transaction
    OXMTransaction * const transaction = self.currentTransaction;
    OXMAbstractCreative *nextCreative = [transaction getCreativeAfter:self.currentCreative];
    if (nextCreative && !self.videoInterstitialDidClose) {
        [self setupCreative:nextCreative];
        return;
    }
    
    // In the case of 300x250 video, the finish of playback does not mean the completion of the ad.
    // User could Watch Again the same creative so it still should be alive. 
    if (self.adConfiguration.isBuiltInVideo) {
        return;
    }
    
    //If there is no next creative, the transaction is complete.
    [self.adViewManagerDelegate adDidComplete];
}

- (void)creativeDidDisplay:(OXMAbstractCreative *)creative {
    self.videoInterstitialDidClose = NO;
    [self.adViewManagerDelegate adDidDisplay];
}

- (void)creativeWasClicked:(OXMAbstractCreative *)creative {
    [self.adViewManagerDelegate adWasClicked];
}

- (void)creativeInterstitialDidClose:(OXMAbstractCreative *) creative {
    if (self.adConfiguration.isOptIn) {
        // In Rewarded Video, the Video remains on the screen with the last frame showing.
        // Cleaning up here when the Interstial is closed.;
        if (self.currentCreative.view && self.currentCreative.view.superview) {
            [self.currentCreative.view removeFromSuperview];
        }
    } else if (self.adConfiguration.adFormat == OXMAdFormatVideo) {
        self.videoInterstitialDidClose = YES;
    }
    
    [self.adViewManagerDelegate adDidClose];
}

- (void)creativeInterstitialDidLeaveApp:(OXMAbstractCreative *) creative {
    [self.adViewManagerDelegate adDidLeaveApp];
}

- (void)creativeClickthroughDidClose:(OXMAbstractCreative *) creative {
    [self.adViewManagerDelegate adClickthroughDidClose];
}

- (void)creativeMraidDidCollapse:(OXMAbstractCreative *) creative {
    [self.adViewManagerDelegate adDidCollapse];
}

- (void)creativeMraidDidExpand:(OXMAbstractCreative *) creative {
    [self.adViewManagerDelegate adDidExpand];
}

//TODO: Describe what implanting means
- (void)creativeReadyToReimplant:(OXMAbstractCreative *)creative {
    UIView *creativeView = creative.view;
    if (!creativeView) {
        return;
    }
    
    if (![self isInterstitial]) {
        [self.adViewManagerDelegate.displayView addSubview:creativeView];
    }
    
    [creativeView OXMAddFillSuperviewConstraints];
}

- (void)creativeViewWasClicked:(OXMAbstractCreative *)creative {
    // POTENTIAL BUG: if publisher did not provide the controller for modal presentation
    // and we did not check it before 'show'
    // the video will disappear from UI and won't appear in the interstitial controller.
    if ([self isAbleToShowCurrentCreative] && !self.adConfiguration.presentAsInterstitial) {
        // IMPORTANT: we have to remove OXMVideoAdView from super view before invoking the show method.
        // Otherwise, the video won't be displayed.
        
        [self.currentCreative.view removeFromSuperview];
        
        self.adConfiguration.forceInterstitialPresentation = @(YES);
        [self.currentCreative.eventManager trackEvent:OXMTrackingEventExpand];
        [self show];
        
        [self.adViewManagerDelegate adViewWasClicked];
    }
}

- (void)creativeFullScreenDidFinish:(OXMAbstractCreative *)creative {
    self.adConfiguration.forceInterstitialPresentation = nil;
    self.currentCreative.creativeModel.adConfiguration.forceInterstitialPresentation = nil;
    [self.currentCreative.eventManager trackEvent:OXMTrackingEventNormal];
    
    [self.currentCreative updateLegalButtonDecorator];
    
    [self.adViewManagerDelegate.displayView addSubview:self.currentCreative.view];
    
    [self.currentCreative displayWithRootViewController:[self.adViewManagerDelegate viewControllerForModalPresentation]];
    
    [self.adViewManagerDelegate adDidClose];
}

#pragma mark - Utility Functions

- (OXMTransaction *)currentTransaction {
    return self.externalTransaction;
}

- (BOOL)isInterstitial {
    return self.adConfiguration.presentAsInterstitial;
}

//Do not load an ad if the current one is "opened"
//Is the current creative an OXMHTMLCreative? If so, is a clickthrough browser visible/MRAID in Expanded mode?
- (BOOL)isCreativeOpened {
    
    OXMTransaction * const transaction = self.currentTransaction;
    if (transaction == nil) {
        return NO;
    }
    
    //TODO: When is there ever a transaction but no current creative?
    if (!self.currentCreative) {
        return NO;
    }
    
    BOOL ret = self.currentCreative.isOpened;
    return ret;
}

// Changes self.creative and calls show & setupRefreshTimer if possible.
- (void)setupCreative:(OXMAbstractCreative *)creative {
    [self setupCreative:creative withThread:NSThread.currentThread];
}

- (void)setupCreative:(OXMAbstractCreative *)creative withThread:(id<OXMNSThreadProtocol>)thread {
    if (!thread.isMainThread) {
        OXMLogError(@"setupCreative must be called on the main thread");
        return;
    }
    
    OXMTransaction * const transaction = self.currentTransaction;
    self.currentCreative.view.hidden = YES;
    self.currentCreative = creative;
    if (self.autoDisplayOnLoad || self.currentCreative != [transaction getFirstCreative]) {
        [self show];
    }
}

#pragma mark - Internal Methods

- (void)onTransactionIsReady:(OXMTransaction *)transaction {
    for (OXMAbstractCreative *creative in transaction.creatives) {
        creative.modalManager = self.modalManager;
    }
        
    //TODO need __block modifier on transaction?
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        //If we're currently displaying a creative, bail.
        if (self.currentCreative) {
            return;
        }
        
        //Otherwise attempt to show the creative.
        [self setupCreative:[transaction getFirstCreative]];
        
        [self.adViewManagerDelegate adLoaded:[transaction getAdDetails]];
    });
}

@end

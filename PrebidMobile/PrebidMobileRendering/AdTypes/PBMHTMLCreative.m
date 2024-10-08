/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//MRAID spec URLs:
//https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
//https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf

#import "PBMAbstractCreative+Protected.h"

#import "NSException+PBMExtensions.h"
#import "NSString+PBMExtensions.h"
#import "UIView+PBMExtensions.h"

#import "PBMConstants.h"
#import "PBMCreativeModel.h"
#import "PBMDeviceAccessManager.h"
#import "PBMDownloadDataHelper.h"
#import "PBMError.h"
#import "PBMFunctions+Private.h"
#import "PBMHTMLCreative.h"
#import "PBMHTMLFormatter.h"
#import "PBMMacros.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMModalViewController.h"
#import "PBMMRAIDCommand.h"
#import "PBMMRAIDConstants.h"
#import "PBMTransaction.h"
#import "PBMVideoView.h"
#import "PBMWebView.h"
#import "PBMWebViewDelegate.h"
#import "PBMMRAIDController.h"
#import "PBMCreativeViewabilityTracker.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Private Extension

@interface PBMAbstractCreative() <PBMWebViewDelegate>
@end

@interface PBMHTMLCreative()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) PBMWebView *prebidWebView;
@property (nonatomic, strong) Prebid *sdkConfiguration;
@property (nonatomic, strong) PBMMRAIDController *MRAIDController;

@property (nonatomic, strong) PBMRewardedConfig *rewardedConfig;
@property (nonatomic, strong, nullable) PBMBackgroundAwareTimer *backgroundAwareTimer;

@end

#pragma mark - Implementation

@implementation PBMHTMLCreative

#pragma mark - Initialization

- (nonnull instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                                  transaction:(PBMTransaction *)transaction {
    self = [self initWithCreativeModel:creativeModel
                           transaction:transaction
                               webView:nil
                      sdkConfiguration:Prebid.shared];
    
    return self;
}

- (nonnull instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                                  transaction:(PBMTransaction *)transaction
                                      webView:(PBMWebView *)webView
                             sdkConfiguration:(Prebid *)sdkConfiguration {
    self = [super initWithCreativeModel:creativeModel transaction:transaction];
    if (self) {
        self.sdkConfiguration = sdkConfiguration;
        
        // TODO: set proper base URL for prebid
        //Set the baseURL. This will cause relative URLs in the creative to inherit the URL scheme used.
        self.baseURL = nil;
        
        if (webView) {
            self.prebidWebView = webView;
        }
        
        self.rewardedConfig = self.creativeModel.adConfiguration.rewardedConfig;
    }
    
    return self;
}

#pragma mark - PBMAbstractCreative

- (BOOL)isOpened {
    return self.clickthroughVisible || (self.MRAIDController && self.MRAIDController.mraidState != PBMMRAIDStateDefault);
}

- (NSNumber *)displayInterval {
    return self.creativeModel.displayDurationInSeconds;
}

- (void)setupView {
    [super setupView];
    
    NSString *html = self.creativeModel.html;
    if (!html) {
        [self onResolutionFailed:[PBMError errorWithDescription:@"No HTML in creative data"]];
        return;
    }
    
    //check if we receive vast data instead of banner
    if (html && [self hasVastTag:html]) {
        [self onResolutionFailed:[PBMError errorWithDescription:@"Wrong data format (VAST) detected for display ad request"]];
        return;
    }

    CGRect rect = CGRectMake(0.0, 0.0, self.creativeModel.width, self.creativeModel.height);
    if (!self.prebidWebView) {
        self.prebidWebView = [[PBMWebView alloc] initWithFrame:rect
                                                 creativeModel:self.creativeModel
                                                     targeting:Targeting.shared];
    } else {
        self.prebidWebView.frame = rect;
    }
    
    if (self.creativeModel.isCompanionAd) {
        self.prebidWebView.rewardedAdURL = self.rewardedConfig.endcardEvent;
    } else {
        self.prebidWebView.rewardedAdURL = self.rewardedConfig.bannerEvent;
    }
    
    self.prebidWebView.delegate = self;
    self.view = self.prebidWebView;
    
    [self loadHTMLToWebView];
}

- (BOOL)hasVastTag:(NSString *)html {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(\\s*)VAST(\\s{1,})version(\\s*)=" options:0 error:NULL];
    NSRange range = NSMakeRange(0, html.length);
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:html options:0 range:range];

    return numberOfMatches > 0;
}
                     
 - (id <PBMUIApplicationProtocol>)getApplication {
     return [UIApplication sharedApplication];
 }

- (void)displayWithRootViewController:(UIViewController*)viewController {
    //Either these constraints are redundant or the initWithFrame is.
    [self.prebidWebView PBMAddCropAndCenterConstraintsWithInitialWidth:self.prebidWebView.frame.size.width initialHeight:self.prebidWebView.frame.size.height];
    [self.prebidWebView prepareForMRAIDWithRootViewController:viewController];

    [super displayWithRootViewController:viewController];

    if (self.creativeModel.isCompanionAd == YES) {
        [self.eventManager trackEvent:PBMTrackingEventCreativeView];

        // For rewarded we have different logic for display completion.
        // See `setupRewardTimerIfNeeded` for more details
        if (!self.creativeModel.adConfiguration.isRewarded) {
            [self.modalManager creativeDisplayCompleted:self];
        }
    }
    
    [self.viewabilityTracker start];
}

- (void)onAdDisplayed {
    [super onAdDisplayed];
    [self setupDisplayTimer];
    [self setupRewardTimerIfNeeded];
}

- (void)setupDisplayTimer {
    //Banners display for a set amount of time and then signal creativeDidComplete.
    //Interstitials display for as long as the user is enjoying their presence.
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        return;
    }
        
    NSTimeInterval displayInterval = [[self displayInterval] doubleValue];

    if (displayInterval <= 0) {
        //Treat as "display forever"
        return;
    }
        
    @weakify(self);
    dispatch_after([PBMFunctions dispatchTimeAfterTimeInterval:displayInterval], dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        //If its open, don't count this as a creativeDidComplete. Re-start the display timer.
        if ([self isOpened]) {
            [self setupDisplayTimer];
        } else {
            [self.creativeViewDelegate creativeDidComplete:self];
        }
    });
}

- (void)setupRewardTimerIfNeeded {
    // NOTE: Rewarded API only
    // Signal to the application that the user has earned the reward after
    // the certain period of time that the ad is on the screen.
    if (!self.creativeModel.adConfiguration.isRewarded) {
        return;
    }
    
    if (!self.rewardedConfig) {
        return;
    }
    
    NSTimeInterval rewardNotificationInterval = 0.0;
    
    if (self.creativeModel.isCompanionAd) {
        NSNumber * videoEndcardTime = self.rewardedConfig.endcardTime;
        NSNumber * defaultEndcardTime = self.rewardedConfig.defaultCompletionTime;
        rewardNotificationInterval = (videoEndcardTime) ? [videoEndcardTime intValue] : [defaultEndcardTime intValue];
    } else {
        NSNumber * bannerEndcardTime = self.rewardedConfig.bannerTime;
        NSNumber * defaultBannerTime = self.rewardedConfig.defaultCompletionTime;
        rewardNotificationInterval = (bannerEndcardTime) ? [bannerEndcardTime intValue] : [defaultBannerTime intValue];
    }
    
    self.backgroundAwareTimer = [PBMBackgroundAwareTimer new];
    
    // Track user did earn reward
    @weakify(self);
    [self.backgroundAwareTimer startTimerWith:rewardNotificationInterval
                                   completion:^{
        @strongify(self);
        
        if (!self) { return; }
        
        if (!self.creativeModel.userHasEarnedReward) {
            self.creativeModel.userHasEarnedReward = YES;
            [self.creativeViewDelegate creativeDidSendRewardedEvent:self];
        }
        
        // Track post reward event
        [self setupPostRewardTimer];
    }];
}

- (void)setupPostRewardTimer {
    // NOTE: Rewarded API only
    // Signal to the SDK about the post reward event in order to execute close ad logic.
    if (!self.creativeModel.adConfiguration.isRewarded) {
        return;
    }
    
    if (!self.rewardedConfig) {
        return;
    }
    
    NSTimeInterval postRewardTime = [self.rewardedConfig.postRewardTime doubleValue] ?: 0;
    
    if (postRewardTime < 0.0 || !self.creativeModel.userHasEarnedReward ||
        self.creativeModel.userPostRewardEventSent) {
        return;
    }
    
    self.backgroundAwareTimer = [PBMBackgroundAwareTimer new];
    
    // Track user did earn reward
    @weakify(self);
    [self.backgroundAwareTimer startTimerWith:postRewardTime
                                   completion:^{
        @strongify(self);
        
        if (!self) { return; }
        
        if (!self.creativeModel.userPostRewardEventSent) {
            self.creativeModel.userPostRewardEventSent = YES;
            [self.modalManager creativeDisplayCompleted:self];
        }
    }];
}


// The session must be created only after WebView finishes loading
- (void)createOpenMeasurementSession {
    
    if (!NSThread.currentThread.isMainThread) {
        PBMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
                    
    self.transaction.measurementSession = [self.transaction.measurementWrapper initializeWebViewSession:self.prebidWebView.internalWebView
                                                                                             contentUrl:@""];
    if (self.transaction.measurementSession) {
        [self.prebidWebView addFriendlyObstructionsToMeasurementSession:self.transaction.measurementSession];
        [self.transaction.measurementSession start];
    }
}

- (void)onWillTrackImpression {
    [super onWillTrackImpression];
    [self.eventManager trackEvent:PBMTrackingEventLoaded];
}

- (void)loadHTMLToWebView {
    
    NSString *html = self.creativeModel.html;
    NSString *htmlWithBodyAndHTMLTags = [PBMHTMLFormatter ensureHTMLHasBodyAndHTMLTags:html];
    
    NSError *error;
    NSString *htmlWithMeasurementJS = [self.transaction.measurementWrapper injectJSLib:htmlWithBodyAndHTMLTags error:&error];
    if (error) {
        PBMLogError(@"PBMWebView can't inject Open Measurement JS lib with error: %@", [error localizedDescription]);
    }
    
    [self.prebidWebView loadHTML:htmlWithMeasurementJS ?: htmlWithBodyAndHTMLTags
                        baseURL:self.baseURL
                  injectMraidJs:YES];
}

#pragma mark - PBMWebViewDelegate

- (void)webViewReadyToDisplay:(PBMWebView *)webView {
    PBMLogInfo(@"PBMWebView is ready to display");
    
    [self onResolutionCompleted];
}

- (void)webView:(PBMWebView *)webView failedToLoadWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

- (void)webView:(PBMWebView *)webView receivedClickthroughLink:(NSURL *)url {
    [self handleClickthrough:url sdkConfiguration:self.sdkConfiguration];
}

- (void)webView:(PBMWebView *)webView receivedMRAIDLink:(NSURL *)url {
    @try {
        if (![self.view isKindOfClass:[PBMWebView class]]) {
            PBMLogWarn(@"Could not cast creative view to PBMWebView");
            return;
        }
        
        if (!self.MRAIDController) {
            self.MRAIDController = [[PBMMRAIDController alloc] initWithCreative:self
                                                    viewControllerForPresenting:self.viewControllerForPresentingModals
                                                                        webView:self.prebidWebView
                                                           creativeViewDelegate:self.creativeViewDelegate
                                                                  downloadBlock:self.downloadBlock];
        }
        [self.MRAIDController webView:webView handleMRAIDURL:url];
    } @catch (NSException *exception) {
        PBMLogWarn(@"%@", [exception reason]);
    }
}

- (void)webView:(PBMWebView *)webView receivedRewardedEventLink:(NSURL *)url {
    if (!self.creativeModel.userHasEarnedReward) {
        [self.creativeViewDelegate creativeDidSendRewardedEvent:self];
        self.creativeModel.userHasEarnedReward = YES;
        
        [self setupPostRewardTimer];
    }
}

#pragma mark - PBMModalManagerDelegate

- (void)modalManagerDidFinishPop:(PBMModalState *)state {
    
    // TODO: Refactor
    // This method illustrates very precisely that we should have different creatives
    // for Banner/Interstitial/MRAID ads.
    // We should use OOP approach for logic encapsulation instead of 'if' logic.

    // Clickthrough
    if (self.clickthroughVisible) {
        [self.creativeViewDelegate creativeClickthroughDidClose:self];
        self.clickthroughVisible = NO;
        
        return;
    }
    
    // EndCard
    if (self.creativeModel.isCompanionAd) {
        // Dismiss parent VideoCreative
        PBMVoidBlock dismissParent = [self.transaction getFirstCreative].dismissInterstitialModalState;
        if (dismissParent) {
            dismissParent();
        }
    }
    
    if (self.MRAIDController) {
        [self.creativeViewDelegate creativeReadyToReimplant:self];
        [self.MRAIDController updateForClose:self.creativeModel.adConfiguration.presentAsInterstitial];
    }

    //Creative presented as Interstitial
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        [self.creativeViewDelegate creativeDidComplete:self];
    }
    
    [self.creativeViewDelegate creativeInterstitialDidClose:self];
}

- (void)modalManagerDidLeaveApp:(PBMModalState*) state {
    [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
}

#pragma mark - Helper Methods

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(Prebid *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(PBMVoidBlock)onClickthroughExitBlock {
    @weakify(self);
    [super handleClickthrough:url
             sdkConfiguration:self.sdkConfiguration
            completionHandler:^void(BOOL success) {
        @strongify(self);
        if (!self) { return; }
        
        if (success) {
            [self.creativeViewDelegate creativeWasClicked:self];
            if (self.creativeModel.isCompanionAd) {
                [self.eventManager trackEvent:PBMTrackingEventCompanionClick];
            } else {
                [self.eventManager trackEvent:PBMTrackingEventClick];
            }
        }
        
        completion(success);
    } onExit:onClickthroughExitBlock];
}

@end

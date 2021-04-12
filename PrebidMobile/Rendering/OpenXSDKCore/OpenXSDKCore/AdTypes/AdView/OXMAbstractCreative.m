//
//  OXMAbstractCreative.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//
#import <StoreKit/SKStoreProductViewController.h>

#import "OXMAbstractCreative+Protected.h"
#import "OXMAbstractCreative.h"
#import "OXMAdConfiguration.h"
#import "OXAClickthroughBrowserOpener.h"
#import "OXMCreativeModel.h"
#import "OXMCreativeResolutionDelegate.h"
#import "OXMCreativeViewabilityTracker.h"
#import "OXMDeepLinkPlusHelper.h"
#import "OXMDeferredModalState.h"
#import "OXMEventManager.h"
#import "OXMFunctions+Private.h"
#import "OXMFunctions.h"
#import "OXMMacros.h"
#import "OXMModalManager.h"
#import "OXMModalState.h"
#import "OXMModalViewController.h"
#import "OXMNSThreadProtocol.h"
#import "OXMOpenMeasurementSession.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXASDKConfiguration.h"
#import "OXMTransaction.h"
#import "OXMWindowLocker.h"

@interface OXMAbstractCreative() <SKStoreProductViewControllerDelegate>

@property (nonatomic, weak, readwrite) OXMTransaction *transaction;
@property (nonatomic, strong, readwrite) OXMEventManager *eventManager;
@property (nonatomic, copy, nullable, readwrite) OXMVoidBlock dismissInterstitialModalState;

@property (nonatomic, assign) BOOL adWasShown;

@end

@implementation OXMAbstractCreative

#pragma mark - Init

- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                          transaction:(OXMTransaction *)transaction {
    self = [super init];
    if (self) {
        OXMAssert(creativeModel);
        
        self.clickthroughVisible = NO;
        self.isDownloaded = NO;
        self.creativeModel = creativeModel;
        self.transaction = transaction;
        self.dispatchQueue = dispatch_queue_create("OXMAbstractCreative", NULL);

        self.eventManager = [OXMEventManager new];
        if (creativeModel.eventTracker) {
            [self.eventManager registerTracker: (id<OXMEventTrackerProtocol>)creativeModel.eventTracker];
        } else {
            OXMLogError(@"Creative model must be provided with event tracker");
        }

    }

    return self;
}

- (void)dealloc {
    [self.viewabilityTracker stop];
    self.viewabilityTracker = NULL;
    OXMLogWhereAmI();
}

#pragma mark - Properties

- (BOOL)isOpened {
    return NO;
}

- (NSNumber *)displayInterval {
    return nil;
}

#pragma mark - Public

- (void)setupView {
    [self setupViewWithThread:NSThread.currentThread];
}

- (void)setupViewWithThread:(id<OXMNSThreadProtocol>)thread {
    if (!thread.isMainThread) {
        OXMLogError(@"Attempting to set up view on background thread");
    }
}

- (void)displayWithRootViewController:(UIViewController*)viewController {
    if (viewController == nil) {
        OXMLogError(@"viewController is nil");
        return;
    }
    self.viewControllerForPresentingModals = viewController;
    if (self.creativeModel.adConfiguration.isInterstitialAd) { // raw value access intended
        self.adWasShown = NO;
    }
    if (!self.adWasShown) {
        self.viewabilityTracker = [[OXMCreativeViewabilityTracker alloc] initWithCreative:self];
    }
}

- (void)showAsInterstitialFromRootViewController:(UIViewController*)uiViewController displayProperties:(OXMInterstitialDisplayProperties*)displayProperties {
    //This containerView will be stretched to fit the available screen.
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:self.view];
    
    displayProperties.closeDelayLeft = displayProperties.closeDelay;
    
    [self updateLegalButtonDecorator];
    
    //Create ModalState and push

    @weakify(self);
    OXMModalState *state = [OXMModalState modalStateWithView:containerView
                                             adConfiguration:self.creativeModel.adConfiguration
                                           displayProperties:displayProperties
                                          onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
        @strongify(self);
        [self modalManagerDidFinishPop:poppedState];
    } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
        @strongify(self);
        [self modalManagerDidLeaveApp:leavingState];
    }];
    
    self.dismissInterstitialModalState = [self.modalManager pushModal:state fromRootViewController:uiViewController animated:YES shouldReplace:NO completionHandler:^{
        [self displayWithRootViewController:uiViewController];
        [self.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.transaction.measurementSession];
    }];
}

- (void)handleClickthrough:(NSURL*)url {
    // Call overridden method with empty non-null closures
    [self handleClickthrough:url
            sdkConfiguration:OXASDKConfiguration.singleton
           completionHandler:^(BOOL success){}
                      onExit:^{}];
}

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration {
    [self handleClickthrough:url
            sdkConfiguration:sdkConfiguration
           completionHandler:^(BOOL success){}
                      onExit:^{}];
}

- (void)handleClickthrough:(NSURL*)url
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(OXMVoidBlock)onClickthroughExitBlock {
    [self handleClickthrough:url
            sdkConfiguration:OXASDKConfiguration.singleton
           completionHandler:completion
                      onExit:onClickthroughExitBlock];
}

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(OXMVoidBlock)onClickthroughExitBlock {
    if (self.creativeModel.adConfiguration.clickHandlerOverride != nil) {
        completion(YES);
        self.creativeModel.adConfiguration.clickHandlerOverride(onClickthroughExitBlock);
        return;
    }
    BOOL clickthroughOpened = NO;
    if (self.transaction.skadnetProductParameters) {
        clickthroughOpened = [self handleProductClickthrough:self.transaction.skadnetProductParameters
                                                      onExit:onClickthroughExitBlock];
    } else {
        
        if ([self handleDeepLinkIfNeeded:url
                        sdkConfiguration:sdkConfiguration
                       completionHandler:completion
                                  onExit:onClickthroughExitBlock]) {
            return;
        }
        
        clickthroughOpened = [self handleNormalClickthrough:url
                                           sdkConfiguration:sdkConfiguration
                                                     onExit:onClickthroughExitBlock];
    }
    
    completion(clickthroughOpened);

    if (!clickthroughOpened) {
        onClickthroughExitBlock();
    }
    return;
}

//checks the given URL and process it if it's a deep link
//return YES if the given URL is deeplink
- (BOOL)handleDeepLinkIfNeeded:(NSURL*)url
              sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
             completionHandler:(void (^)(BOOL success))completion
                        onExit:(OXMVoidBlock)onClickthroughExitBlock {
    NSURL *effectiveURL = url;
    if (self.creativeModel.targetURL != nil) {
        NSURL *overrideURL = [NSURL URLWithString:self.creativeModel.targetURL];
        if (overrideURL != nil) {
            effectiveURL = overrideURL;
        }
    }

    if (![OXMDeepLinkPlusHelper isDeepLinkPlusURL:effectiveURL]) {
        return NO;
    } else {
        @weakify(self);
        [OXMDeepLinkPlusHelper tryHandleDeepLinkPlus:effectiveURL completion:^(BOOL visited, NSURL *_Nullable fallbackURL, NSArray<NSURL *> *_Nullable trackingURLs) {
            @strongify(self);
            if (visited) {
                completion(YES);
                onClickthroughExitBlock();
            } else if (!fallbackURL) {
                completion(NO);
                onClickthroughExitBlock();
            } else {
                BOOL clickthroughOpened = [self handleNormalClickthrough:fallbackURL
                                                        sdkConfiguration:sdkConfiguration
                                                                  onExit:onClickthroughExitBlock];

                completion(clickthroughOpened);

                if (clickthroughOpened) {
                    if (trackingURLs != nil) {
                        [OXMDeepLinkPlusHelper visitTrackingURLs:trackingURLs];
                    }
                } else {
                    onClickthroughExitBlock();
                }
            }
        }];
        return YES;
    }
}

//Returns true if the clickthrough is presented
- (BOOL)handleNormalClickthrough:(NSURL *)url
                sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                          onExit:(nonnull OXMVoidBlock)onClickthroughExitBlock {
    
    @weakify(self);
    
    OXAClickthroughBrowserOpener * const
    clickthroughOpener = [[OXAClickthroughBrowserOpener alloc] initWithSDKConfiguration:sdkConfiguration
                                                                        adConfiguration:self.creativeModel.adConfiguration
                                                                           modalManager:self.modalManager
                                                                 viewControllerProvider:^UIViewController * _Nullable{
        @strongify(self);
        return self.viewControllerForPresentingModals;
    } measurementSessionProvider: ^OXMOpenMeasurementSession * _Nullable{
        @strongify(self);
        return self.transaction.measurementSession;
    } onWillLoadURLInClickthrough:^{
        @strongify(self);
        self.clickthroughVisible = YES;
    } onWillLeaveAppBlock:^{
        @strongify(self);
        [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
    } onClickthroughPoppedBlock:^(OXMModalState * _Nonnull poppedState) {
        @strongify(self);
        [self modalManagerDidFinishPop:poppedState];
    } onDidLeaveAppBlock:^(OXMModalState * _Nonnull leavingState) {
        @strongify(self);
        [self modalManagerDidLeaveApp:leavingState];
    }];
    
    return [clickthroughOpener openURL:url onClickthroughExitBlock:onClickthroughExitBlock];
}

- (BOOL)handleProductClickthrough:(NSDictionary<NSString *, id> *)productParams
                           onExit:(nonnull OXMVoidBlock)onClickthroughExitBlock
{
    if (!self.viewControllerForPresentingModals) {
        OXMLogError(@"self.viewControllerForPresentingModals is nil");
        return NO;
    }
    
    if (@available(iOS 14, *)) {
        
        if (self.viewControllerForPresentingModals.presentedViewController) {
            [self.viewControllerForPresentingModals.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SKStoreProductViewController *skadnController = [SKStoreProductViewController new];
            skadnController.delegate = self;
            [self.viewControllerForPresentingModals presentViewController:skadnController animated:YES completion:nil];
            [skadnController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
                if (error) {
                    OXMLogError(@"Error presenting a product: %@", error.localizedDescription);
                }
            }];
        });
    }

    return YES;
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.creativeViewDelegate creativeClickthroughDidClose:self];
}

// Helper methods for resolution success & failure
- (void)onResolutionCompleted {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);

        if (self.isDownloaded) {
            return;
        }

        self.isDownloaded = YES;
        
        [self.creativeResolutionDelegate creativeReady:self];
    });
}

- (void)onResolutionFailed:(nonnull NSError *)error {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        
        if (self.isDownloaded) {
            return;
        }
        
        self.isDownloaded = YES;
        [self.creativeResolutionDelegate creativeFailed:error];
    });
}

- (void)onViewabilityChanged:(BOOL)viewable viewExposure:(OXMViewExposure *)viewExposure {
    if (viewable && !self.adWasShown) {
        [self onAdDisplayed];
        self.adWasShown = YES;
    }
}

- (void)updateLegalButtonDecorator {
    // Implement in particular creatives
}

- (void)pause {
    // Implement in particular creatives
}

- (void)resume {
    // Implement in particular creatives
}

- (void)mute {
    // Implement in particular creatives
}

- (void)unmute {
    // Implement in particular creatives
}

- (BOOL)isMuted {
    return FALSE;
}

- (void)onWillTrackImpression {
    // Implement in particular creatives
}

#pragma mark - OXMModalManagerDelegate

- (void)modalManagerDidFinishPop:(OXMModalState*)state {
    OXMLogError(@"Abstract function called");
}

- (void)modalManagerDidLeaveApp:(OXMModalState*)state {
    OXMLogError(@"Abstract function called");
}

#pragma mark - Open Measurement

- (void)createOpenMeasurementSession {
    OXMLogError(@"Abstract function called");
}

- (void)onAdDisplayed {
    [self.eventManager registerTracker:self.transaction.measurementSession.eventTracker];

    [self.creativeViewDelegate creativeDidDisplay:self];
    [self onWillTrackImpression];
    [self.eventManager trackEvent:OXMTrackingEventImpression];
}

@end

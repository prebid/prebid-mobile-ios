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

#import <StoreKit/SKStoreProductViewController.h>
#import <WebKit/WebKit.h>

#import "PBMAbstractCreative+Protected.h"
#import "PBMAbstractCreative.h"
#import "PBMAdConfiguration.h"
#import "PBMClickthroughBrowserOpener.h"
#import "PBMCreativeModel.h"
#import "PBMCreativeResolutionDelegate.h"
#import "PBMCreativeViewabilityTracker.h"
#import "PBMDeepLinkPlusHelper.h"
#import "PBMDeferredModalState.h"
#import "PBMEventManager.h"
#import "PBMFunctions+Private.h"
#import "PBMFunctions.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMMacros.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMModalViewController.h"
#import "PBMNSThreadProtocol.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMTransaction.h"
#import "PBMWindowLocker.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@interface PBMAbstractCreative() <SKStoreProductViewControllerDelegate>

@property (nonatomic, weak, readwrite) PBMTransaction *transaction;
@property (nonatomic, strong, readwrite) PBMEventManager *eventManager;
@property (nonatomic, copy, nullable, readwrite) PBMVoidBlock dismissInterstitialModalState;

@property (nonatomic, assign) BOOL adWasShown;

@property (nonatomic, nonnull) WKWebView *hiddenWebView;

@end

@implementation PBMAbstractCreative

#pragma mark - Init

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                          transaction:(PBMTransaction *)transaction {
    self = [super init];
    if (self) {
        PBMAssert(creativeModel);
        
        self.clickthroughVisible = NO;
        self.isDownloaded = NO;
        self.creativeModel = creativeModel;
        self.transaction = transaction;
        self.dispatchQueue = dispatch_queue_create("PBMAbstractCreative", NULL);

        self.eventManager = [PBMEventManager new];
        if (creativeModel.eventTracker) {
            [self.eventManager registerTracker: (id<PBMEventTrackerProtocol>)creativeModel.eventTracker];
        } else {
            PBMLogError(@"Creative model must be provided with event tracker");
        }
        
        if(@available(iOS 14.5, *)) {
            if (self.transaction.skadInfo) {
                SKAdImpression *imp = [SkadnParametersManager getSkadnImpressionFor:self.transaction.skadInfo];
                if (imp) {
                    SkadnEventTracker *skadnTracker = [[SkadnEventTracker alloc] initWith:imp];
                    [self.eventManager registerTracker:(id<PBMEventTrackerProtocol>) skadnTracker];
                }
            }
        }

    }

    return self;
}

- (void)dealloc {
    [self.viewabilityTracker stop];
    self.viewabilityTracker = NULL;
    PBMLogWhereAmI();
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

- (void)setupViewWithThread:(id<PBMNSThreadProtocol>)thread {
    if (!thread.isMainThread) {
        PBMLogError(@"Attempting to set up view on background thread");
    }
}

- (void)displayWithRootViewController:(UIViewController*)viewController {
    if (viewController == nil) {
        PBMLogError(@"viewController is nil");
        return;
    }
    self.viewControllerForPresentingModals = viewController;
    if (self.creativeModel.adConfiguration.isInterstitialAd) { // raw value access intended
        self.adWasShown = NO;
    }
    if (!self.adWasShown) {
        self.viewabilityTracker = [[PBMCreativeViewabilityTracker alloc] initWithCreative:self];
    }
}

- (void)showAsInterstitialFromRootViewController:(UIViewController*)uiViewController displayProperties:(PBMInterstitialDisplayProperties*)displayProperties {
    //This containerView will be stretched to fit the available screen.
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:self.view];
    
    displayProperties.closeDelayLeft = displayProperties.closeDelay;
    
    //Create ModalState and push

    @weakify(self);
    PBMModalState *state = [PBMModalState modalStateWithView:containerView
                                             adConfiguration:self.creativeModel.adConfiguration
                                           displayProperties:displayProperties
                                          onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
        @strongify(self);
        [self modalManagerDidFinishPop:poppedState];
    } onStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
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
            sdkConfiguration:PrebidConfiguration.shared
           completionHandler:^(BOOL success){}
                      onExit:^{}];
}

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(PrebidConfiguration *)sdkConfiguration {
    [self handleClickthrough:url
            sdkConfiguration:sdkConfiguration
           completionHandler:^(BOOL success){}
                      onExit:^{}];
}

- (void)handleClickthrough:(NSURL*)url
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(PBMVoidBlock)onClickthroughExitBlock {
    [self handleClickthrough:url
            sdkConfiguration:PrebidConfiguration.shared
           completionHandler:completion
                      onExit:onClickthroughExitBlock];
}

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(PrebidConfiguration *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(PBMVoidBlock)onClickthroughExitBlock {
    self.hiddenWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    HiddenWebViewManager *webViewManager = [[HiddenWebViewManager alloc] initWithWebView:self.hiddenWebView landingPageString:url.absoluteString];
    [self.hiddenWebView setHidden:YES];
    [webViewManager openHiddenWebView];
    
    if (self.creativeModel.adConfiguration.clickHandlerOverride != nil) {
        completion(YES);
        self.creativeModel.adConfiguration.clickHandlerOverride(onClickthroughExitBlock);
        return;
    }
    BOOL clickthroughOpened = NO;
    PBMJsonDictionary * skadnetProductParameters = [SkadnParametersManager getSkadnProductParametersFor:self.transaction.skadInfo];
    
    if (skadnetProductParameters) {
        clickthroughOpened = [self handleProductClickthrough:skadnetProductParameters
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
              sdkConfiguration:(PrebidConfiguration *)sdkConfiguration
             completionHandler:(void (^)(BOOL success))completion
                        onExit:(PBMVoidBlock)onClickthroughExitBlock {
    NSURL *effectiveURL = url;
    if (self.creativeModel.targetURL != nil) {
        NSURL *overrideURL = [NSURL URLWithString:self.creativeModel.targetURL];
        if (overrideURL != nil) {
            effectiveURL = overrideURL;
        }
    }

    if (![PBMDeepLinkPlusHelper isDeepLinkPlusURL:effectiveURL]) {
        return NO;
    } else {
        @weakify(self);
        [PBMDeepLinkPlusHelper tryHandleDeepLinkPlus:effectiveURL completion:^(BOOL visited, NSURL *_Nullable fallbackURL, NSArray<NSURL *> *_Nullable trackingURLs) {
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
                        [PBMDeepLinkPlusHelper visitTrackingURLs:trackingURLs];
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
                sdkConfiguration:(PrebidConfiguration *)sdkConfiguration
                          onExit:(nonnull PBMVoidBlock)onClickthroughExitBlock {
    
    @weakify(self);
    
    PBMClickthroughBrowserOpener * const
    clickthroughOpener = [[PBMClickthroughBrowserOpener alloc] initWithSDKConfiguration:sdkConfiguration
                                                                        adConfiguration:self.creativeModel.adConfiguration
                                                                           modalManager:self.modalManager
                                                                 viewControllerProvider:^UIViewController * _Nullable{
        @strongify(self);
        return self.viewControllerForPresentingModals;
    } measurementSessionProvider: ^PBMOpenMeasurementSession * _Nullable{
        @strongify(self);
        return self.transaction.measurementSession;
    } onWillLoadURLInClickthrough:^{
        @strongify(self);
        self.clickthroughVisible = YES;
    } onWillLeaveAppBlock:^{
        @strongify(self);
        [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
    } onClickthroughPoppedBlock:^(PBMModalState * _Nonnull poppedState) {
        @strongify(self);
        [self modalManagerDidFinishPop:poppedState];
    } onDidLeaveAppBlock:^(PBMModalState * _Nonnull leavingState) {
        @strongify(self);
        [self modalManagerDidLeaveApp:leavingState];
    }];
    
    return [clickthroughOpener openURL:url onClickthroughExitBlock:onClickthroughExitBlock];
}

- (BOOL)handleProductClickthrough:(NSDictionary<NSString *, id> *)productParams
                           onExit:(nonnull PBMVoidBlock)onClickthroughExitBlock
{
    if (!self.viewControllerForPresentingModals) {
        PBMLogError(@"self.viewControllerForPresentingModals is nil");
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
                    PBMLogError(@"Error presenting a product: %@", error.localizedDescription);
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

- (void)onViewabilityChanged:(BOOL)viewable viewExposure:(PBMViewExposure *)viewExposure {
    if (viewable && !self.adWasShown) {
        [self onAdDisplayed];
        self.adWasShown = YES;
    }
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

#pragma mark - PBMModalManagerDelegate

- (void)modalManagerDidFinishPop:(PBMModalState*)state {
    PBMLogError(@"Abstract function called");
}

- (void)modalManagerDidLeaveApp:(PBMModalState*)state {
    PBMLogError(@"Abstract function called");
}

#pragma mark - Open Measurement

- (void)createOpenMeasurementSession {
    PBMLogError(@"Abstract function called");
}

- (void)onAdDisplayed {
    [self.eventManager registerTracker:self.transaction.measurementSession.eventTracker];

    [self.creativeViewDelegate creativeDidDisplay:self];
    [self onWillTrackImpression];
    [self.eventManager trackEvent:PBMTrackingEventImpression];
}

@end

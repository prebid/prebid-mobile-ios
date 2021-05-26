//
//  PBMBaseInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBaseInterstitialAdUnit.h"
#import "PBMBaseInterstitialAdUnit+Protected.h"

#import "PBMAdLoadFlowController.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMError.h"
#import "PBMInterstitialAdLoader.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting.h"
#import "PBMAdViewManager.h"
#import "PBMServerConnection.h"

#import "PBMMacros.h"

#import "PBMPlayable.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMConstants.h"
#import "PBMDataAssetType.h"
#import "PBMJsonCodable.h"

#import "PBMNativeEventType.h"
#import "PBMNativeEventTrackingMethod.h"

#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativePlacementType.h"
#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMImageAssetType.h"
#import "PBMNativeAdElementType.h"

#import "PBMAdFormat.h"

#import "PBMInterstitialControllerInteractionDelegate.h"
#import "PBMRewardedEventInteractionDelegate.h"

#import "PBMAdLoadFlowControllerDelegate.h"
#import "PBMBannerAdLoaderDelegate.h"
#import "PBMBannerEventInteractionDelegate.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"
#import "PBMDisplayViewInteractionDelegate.h"

#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMBaseInterstitialAdUnit () <PBMAdLoadFlowControllerDelegate,
                                         PBMInterstitialAdLoaderDelegate,
                                         PBMInterstitialControllerInteractionDelegate>

@property (nonatomic, strong, nonnull, readonly) PBMAdLoadFlowController *adLoadFlowController;
@property (nonatomic, strong, nonnull, readonly) NSObject *blocksLockToken;

@property (nonatomic, copy, nullable) void (^showBlock)(UIViewController *);
@property (nonatomic, strong, nullable) void (^currentAdBlock)(UIViewController *);
@property (atomic, copy, nullable) BOOL (^isReadyBlock)(void);

@property (nonatomic, weak, nullable) UIViewController *targetController;

@end


@implementation PBMBaseInterstitialAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId
                     minSizePerc:(nullable NSValue *)minSizePerc
                    eventHandler:(id)eventHandler {
    if (!(self = [super init])) {
        return nil;
    }
    
    _adUnitConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configId];
    _adUnitConfig.isInterstitial = YES;
    _adUnitConfig.minSizePerc = minSizePerc;
    _adUnitConfig.adPosition = PBMAdPosition_FullScreen;
    _adUnitConfig.videoPlacementType = 5;   //Fullscreen
    _eventHandler = eventHandler;
    _blocksLockToken = [[NSObject alloc] init];
    
    PBMInterstitialAdLoader * const interstitialAdLoader = [[PBMInterstitialAdLoader alloc] initWithDelegate:self];
    [self callEventHandler_setLoadingDelegate:interstitialAdLoader];
    
    PBMAdUnitConfigValidationBlock const configValidator = ^BOOL(PBMAdUnitConfig *adUnitConfig, BOOL renderWithPrebid) {
        return YES;
    };

    _adLoadFlowController = [[PBMAdLoadFlowController alloc]
                             initWithBidRequesterFactory:^id<PBMBidRequesterProtocol> (PBMAdUnitConfig * adUnitConfig) {
        return [[PBMBidRequester alloc] initWithConnection:[PBMServerConnection singleton]
                                          sdkConfiguration:[PBMSDKConfiguration singleton]
                                                 targeting:[PBMTargeting shared]
                                       adUnitConfiguration:adUnitConfig];
    }
                             adLoader:interstitialAdLoader
                             delegate:self
                             configValidationBlock:configValidator];
    
    return self;
}

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(id)eventHandler
{
    return (self = [self initWithConfigId:configId minSizePerc:@(minSizePercentage) eventHandler:eventHandler]);
}

- (instancetype)initWithConfigId:(NSString *)configId eventHandler:(id)eventHandler {
    return (self = [self initWithConfigId:configId minSizePerc:nil eventHandler:eventHandler]);
}

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage {
    return (self = [self initWithConfigId:configId minSizePerc:@(minSizePercentage) eventHandler:nil]);
}

- (instancetype)initWithConfigId:(NSString *)configId {
    return (self = [self initWithConfigId:configId minSizePerc:nil eventHandler:nil]);
}

// MARK: - Computed properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

- (PBMAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(PBMAdFormat)adFormat {
    self.adUnitConfig.adFormat = adFormat;
}

- (BOOL)isReady {
    @synchronized (self.blocksLockToken) {
        if (!self.isReadyBlock) {
            return NO;
        }
        return self.isReadyBlock();
    }
}

// MARK: - Public API

- (void)loadAd {
    [self.adLoadFlowController refresh];
}

- (void)showFromViewController:(UIViewController *)controller {
    // It is expected from the user to call this method on main thread
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    @synchronized (self.blocksLockToken) {
        if (!self.showBlock || self.currentAdBlock) {
            return;
        }
        self.isReadyBlock = nil;
        self.currentAdBlock = self.showBlock;
        self.showBlock = nil;
        [self callDelegate_willPresentAd];
        self.targetController = controller;
        self.currentAdBlock(controller);
    }
}

// MARK: - Context Data

- (void)addContextData:(NSString *)data forKey:(NSString *)key {
    [self.adUnitConfig addContextData:data forKey:key];
}

- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key {
    [self.adUnitConfig updateContextData:data forKey:key];
}

- (void)removeContextDataForKey:(NSString *)key {
    [self.adUnitConfig removeContextDataForKey:key];
}

- (void)clearContextData {
    [self.adUnitConfig clearContextData];
}

// MARK: - PBMInterstitialAdLoaderDelegate

- (void)interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController *))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock
{
    @synchronized (self.blocksLockToken) {
        self.showBlock = showBlock;
        self.isReadyBlock = isReadyBlock;
    }
    [self reportLoadingSuccess];
}

- (void) interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(InterstitialController *)interstitialController
{
    interstitialController.interactionDelegate = self;
}

// MARK: - PBMAdLoadFlowControllerDelegate

- (void)adLoadFlowController:(PBMAdLoadFlowController *)adLoadFlowController failedWithError:(NSError *)error {
    [self reportLoadingFailedWithError:error];
}

- (void)adLoadFlowControllerWillSendBidRequest:(PBMAdLoadFlowController *)adLoadFlowController {
    // nop
}

- (void)adLoadFlowControllerWillRequestPrimaryAd:(PBMAdLoadFlowController *)adLoadFlowController {
    [self callEventHandler_setInteractionDelegate];
}

- (BOOL)adLoadFlowControllerShouldContinue:(PBMAdLoadFlowController *)adLoadFlowController {
    return YES;
}

// MARK: - PBMInterstitialEventInteractionDelegate protocol

- (void)willPresentAd {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_willPresentAd];
    });
}

- (void)didDismissAd {
    @synchronized (self.blocksLockToken) {
        self.currentAdBlock = nil;
    }
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_didDismissAd];
    });
}

- (void)willLeaveApp {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_willLeaveApplication];
    });
}

- (void)didClickAd {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_didClickAd];
    });
}

// MARK: - PBMInterstitialControllerInteractionDelegate protocol

- (void)trackImpressionForInterstitialController:(InterstitialController *)interstitialController {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callEventHandler_trackImpression];
    });
}

- (void)interstitialControllerDidClickAd:(InterstitialController *)interstitialController {
    // This method is called from UI-mutating code
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_didClickAd];
}

- (void)interstitialControllerDidCloseAd:(InterstitialController *)interstitialController {
    // This method is called from UI-mutating code
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_didDismissAd];
}

- (void)interstitialControllerDidLeaveApp:(InterstitialController *)interstitialController {
    // This method is called as the result of UI interaction
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_willLeaveApplication];
}

- (UIViewController *)viewControllerForModalPresentationFrom:(InterstitialController *)interstitialController {
    return self.targetController;
}

// MARK: - Private methods

- (void)reportLoadingSuccess {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_didReceiveAd];
    });
}

- (void)reportLoadingFailedWithError:(nullable NSError *)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_didFailToReceiveAdWithError:error];
    });
}

// MARK: - Abstract methods

- (BOOL)callEventHandler_isReady {
    return NO; // to be overridden in subclass
}

- (void)callDelegate_didReceiveAd {
    // to be overridden in subclass
}

- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error {
    // to be overridden in subclass
}

- (void)callDelegate_willPresentAd {
    // to be overridden in subclass
}

- (void)callDelegate_didDismissAd {
    // to be overridden in subclass
}

- (void)callDelegate_willLeaveApplication {
    // to be overridden in subclass
}

- (void)callDelegate_didClickAd {
    // to be overridden in subclass
}

- (void)callEventHandler_setLoadingDelegate:(id<PBMRewardedEventLoadingDelegate>)loadingDelegate {
    // to be overridden in subclass
}

- (void)callEventHandler_setInteractionDelegate {
    // to be overridden in subclass
}

- (void)callEventHandler_requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse {
    // to be overridden in subclass
}

- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller {
    // to be overridden in subclass
}

- (void)callEventHandler_trackImpression {
    // to be overridden in subclass
}


@end

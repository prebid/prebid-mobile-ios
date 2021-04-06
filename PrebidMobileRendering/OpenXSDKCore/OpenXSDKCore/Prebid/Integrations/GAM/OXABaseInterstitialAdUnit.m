//
//  OXABaseInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABaseInterstitialAdUnit.h"
#import "OXABaseInterstitialAdUnit+Protected.h"

#import "OXAAdLoadFlowController.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXAError.h"
#import "OXAInterstitialAdLoader.h"
#import "OXAInterstitialController.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXMAdViewManager.h"
#import "OXMServerConnection.h"

#import "OXMMacros.h"

@interface OXABaseInterstitialAdUnit () <OXAAdLoadFlowControllerDelegate, OXAInterstitialAdLoaderDelegate, OXAInterstitialControllerInteractionDelegate>

@property (nonatomic, strong, nonnull, readonly) OXAAdLoadFlowController *adLoadFlowController;
@property (nonatomic, strong, nonnull, readonly) NSObject *blocksLockToken;

@property (nonatomic, copy, nullable) void (^showBlock)(UIViewController *);
@property (nonatomic, strong, nullable) void (^currentAdBlock)(UIViewController *);
@property (atomic, copy, nullable) BOOL (^isReadyBlock)(void);

@property (nonatomic, weak, nullable) UIViewController *targetController;

@end


@implementation OXABaseInterstitialAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId
                     minSizePerc:(nullable NSValue *)minSizePerc
                    eventHandler:(id)eventHandler {
    if (!(self = [super init])) {
        return nil;
    }
    
    _adUnitConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configId];
    _adUnitConfig.isInterstitial = YES;
    _adUnitConfig.minSizePerc = minSizePerc;
    _adUnitConfig.adPosition = OXAAdPosition_FullScreen;
    _adUnitConfig.videoPlacementType = 5;   //Fullscreen
    _eventHandler = eventHandler;
    _blocksLockToken = [[NSObject alloc] init];
    
    OXAInterstitialAdLoader * const interstitialAdLoader = [[OXAInterstitialAdLoader alloc] initWithDelegate:self];
    [self callEventHandler_setLoadingDelegate:interstitialAdLoader];
    
    OXAAdUnitConfigValidationBlock const configValidator = ^BOOL(OXAAdUnitConfig *adUnitConfig, BOOL renderWithApollo) {
        return YES;
    };

    _adLoadFlowController = [[OXAAdLoadFlowController alloc]
                             initWithBidRequesterFactory:^id<OXABidRequesterProtocol> (OXAAdUnitConfig * adUnitConfig) {
        return [[OXABidRequester alloc] initWithConnection:[OXMServerConnection singleton]
                                          sdkConfiguration:[OXASDKConfiguration singleton]
                                                 targeting:[OXATargeting shared]
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

- (OXAAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(OXAAdFormat)adFormat {
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
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
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

// MARK: - OXAInterstitialAdLoaderDelegate

- (void)interstitialAdLoader:(OXAInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController *))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock
{
    @synchronized (self.blocksLockToken) {
        self.showBlock = showBlock;
        self.isReadyBlock = isReadyBlock;
    }
    [self reportLoadingSuccess];
}

- (void) interstitialAdLoader:(OXAInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(OXAInterstitialController *)interstitialController
{
    interstitialController.interactionDelegate = self;
}

// MARK: - OXAAdLoadFlowControllerDelegate

- (void)adLoadFlowController:(OXAAdLoadFlowController *)adLoadFlowController failedWithError:(NSError *)error {
    [self reportLoadingFailedWithError:error];
}

- (void)adLoadFlowControllerWillSendBidRequest:(OXAAdLoadFlowController *)adLoadFlowController {
    // nop
}

- (void)adLoadFlowControllerWillRequestPrimaryAd:(OXAAdLoadFlowController *)adLoadFlowController {
    [self callEventHandler_setInteractionDelegate];
}

- (BOOL)adLoadFlowControllerShouldContinue:(OXAAdLoadFlowController *)adLoadFlowController {
    return YES;
}

// MARK: - OXAInterstitialEventInteractionDelegate protocol

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

// MARK: - OXAInterstitialControllerInteractionDelegate protocol

- (void)trackImpressionForInterstitialController:(OXAInterstitialController *)interstitialController {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callEventHandler_trackImpression];
    });
}

- (void)interstitialControllerDidClickAd:(OXAInterstitialController *)interstitialController {
    // This method is called from UI-mutating code
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_didClickAd];
}

- (void)interstitialControllerDidCloseAd:(OXAInterstitialController *)interstitialController {
    // This method is called from UI-mutating code
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_didDismissAd];
}

- (void)interstitialControllerDidLeaveApp:(OXAInterstitialController *)interstitialController {
    // This method is called as the result of UI interaction
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    [self callDelegate_willLeaveApplication];
}

- (UIViewController *)viewControllerForModalPresentationFrom:(OXAInterstitialController *)interstitialController {
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

- (void)callEventHandler_setLoadingDelegate:(id<OXARewardedEventLoadingDelegate>)loadingDelegate {
    // to be overridden in subclass
}

- (void)callEventHandler_setInteractionDelegate {
    // to be overridden in subclass
}

- (void)callEventHandler_requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse {
    // to be overridden in subclass
}

- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller {
    // to be overridden in subclass
}

- (void)callEventHandler_trackImpression {
    // to be overridden in subclass
}


@end

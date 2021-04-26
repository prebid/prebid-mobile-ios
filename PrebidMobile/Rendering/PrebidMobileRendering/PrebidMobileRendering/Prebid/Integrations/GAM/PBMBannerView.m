//
//  PBMBannerView.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "UIView+PBMExtensions.h"

#import "PBMBannerView.h"
#import "PBMBannerView+InternalState.h"

#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMNativeAdConfiguration.h"
#import "PBMAdLoadFlowController.h"
#import "PBMAdLoadFlowControllerDelegate.h"
#import "PBMBannerAdLoader.h"
#import "PBMBannerEventInteractionDelegate.h"
#import "PBMBannerEventHandler.h"
#import "PBMBannerEventHandlerStandalone.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"
#import "PBMDisplayViewInteractionDelegate.h"
#import "PBMError.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting.h"
#import "PBMAutoRefreshManager.h"
#import "PBMServerConnection.h"

#import "PBMMacros.h"

@interface PBMBannerView () <PBMAdLoadFlowControllerDelegate, PBMBannerEventInteractionDelegate, PBMDisplayViewInteractionDelegate, PBMBannerAdLoaderDelegate>

// MARK: Readonly storage
@property (nonatomic, strong, nonnull, readonly) PBMAutoRefreshManager *autoRefreshManager;
@property (nonatomic, strong, nonnull, readonly) PBMAdLoadFlowController *adLoadFlowController;

// MARK: Externally observable
@property (nonatomic, strong, nullable) UIView *deployedView;
@property (nonatomic, assign) BOOL isRefreshStopped;
@property (nonatomic, assign) BOOL isAdOpened;

// MARK: Computed helpers
@property (nonatomic, readonly) BOOL mayRefreshNow; /// whether auto-refresh is allowed to occur now
@property (nonatomic, readonly) BOOL isCreativeOpened; /// => (deployedView as? PBMDisplayView).isCreativeOpened

@end


@implementation PBMBannerView

@synthesize eventHandler = _eventHandler;

// MARK: - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size
                 eventHandler:(id<PBMBannerEventHandler>)eventHandler
{
    if(!(self = [super initWithFrame:frame])) {
        return nil;
    }
    
    _adUnitConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configId size:size];
    _eventHandler = eventHandler;
    
    PBMBannerAdLoader * const bannerAdLoader = [[PBMBannerAdLoader alloc] initWithDelegate:self];
    
    _adLoadFlowController = [[PBMAdLoadFlowController alloc]
                             initWithBidRequesterFactory:^id<PBMBidRequesterProtocol> (PBMAdUnitConfig * adUnitConfig) {
        return [[PBMBidRequester alloc] initWithConnection:[PBMServerConnection singleton]
                                          sdkConfiguration:[PBMSDKConfiguration singleton]
                                                 targeting:[PBMTargeting shared]
                                       adUnitConfiguration:adUnitConfig];
    }
                             adLoader:bannerAdLoader
                             delegate:self
                             configValidationBlock:^BOOL(PBMAdUnitConfig * _Nonnull adUnitConfig, BOOL renderWithPrebid)
    {
        if (renderWithPrebid) {
            return [PBMBannerView canPrebidDisplayAd:adUnitConfig];
        } else {
            return [PBMBannerView canEventHandler:eventHandler displayAd:adUnitConfig];
        }
    }];
    
    @weakify(self);
    _autoRefreshManager = [[PBMAutoRefreshManager alloc] initWithPrefetchTime:PBMAdPrefetchTime
                                                                 lockingQueue:_adLoadFlowController.dispatchQueue
                                                                 lockProvider:^ id<NSLocking> {
        @strongify(self);
        return self.adLoadFlowController.mutationLock;
    } refreshDelayBlock:^NSNumber * _Nullable{
        @strongify(self);
        return @(self.adUnitConfig.refreshInterval);
    } mayRefreshNowBlock:^BOOL{
        @strongify(self);
        return [self mayRefreshNow];
    } refreshBlock:^{
        @strongify(self);
        [self.adLoadFlowController refresh];
    }];
    
    return self;
}

- (instancetype)initWithConfigId:(NSString *)configId
                    eventHandler:(id<PBMBannerEventHandler>)eventHandler {
    
    CGSize size =  [eventHandler.adSizes.firstObject CGSizeValue];
    CGRect frame = CGRectMake(CGPointZero.x, CGPointZero.y, size.width, size.height);
    
     self = [self initWithFrame:frame
                       configId:configId
                         adSize:size
                   eventHandler:eventHandler];
    
    const NSUInteger sizesCount = eventHandler.adSizes.count;
    if (sizesCount > 1) {
        self.additionalSizes = [eventHandler.adSizes subarrayWithRange:NSMakeRange(1, sizesCount - 1)];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size
{
    return (self = [self initWithFrame:frame
                              configId:configId
                                adSize:size
                          eventHandler:[[PBMBannerEventHandlerStandalone alloc] init]]);
}

// MARK: - Computed public properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

- (NSTimeInterval)refreshInterval {
    return self.adUnitConfig.refreshInterval;
}

- (void)setRefreshInterval:(NSTimeInterval)refreshInterval {
    self.adUnitConfig.refreshInterval = refreshInterval;
}

- (NSArray<NSValue *> *)additionalSizes {
    return self.adUnitConfig.additionalSizes;
}

- (void)setAdditionalSizes:(NSArray<NSValue *> *)additionalSizes {
    self.adUnitConfig.additionalSizes = additionalSizes;
}

- (PBMAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(PBMAdFormat)adFormat {
    self.adUnitConfig.adFormat = adFormat;
}

- (void)setAdPosition:(PBMAdPosition)adPosition {
    self.adUnitConfig.adPosition = adPosition;
}

- (PBMAdPosition)adPosition {
    return self.adUnitConfig.adPosition;
}

- (PBMVideoPlacementType)videoPlacementType {
    return self.adUnitConfig.videoPlacementType;
}

- (void)setVideoPlacementType:(PBMVideoPlacementType)videoPlacementType {
    self.adUnitConfig.videoPlacementType = videoPlacementType;
}

- (PBMNativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

- (void)setNativeAdConfig:(PBMNativeAdConfiguration *)nativeAdConfig {
    self.adUnitConfig.nativeAdConfig = nativeAdConfig;
}

// MARK: - Public Methods

// See: https://openxtechinc.atlassian.net/wiki/spaces/MOB/pages/852328648/Banner+Refresh+Policy
- (void)loadAd {
    [self.adLoadFlowController refresh];
}

- (void)stopRefresh {
    @weakify(self);
    [self.adLoadFlowController enqueueGatedBlock:^{
        @strongify(self);
        self.isRefreshStopped = YES;
    }];
}

// MARK: - PBMBannerEventInteractionDelegate

- (void)willPresentModal {
    // This method is called from UI-mutating code
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    self.isAdOpened = YES;
    id<PBMBannerViewDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bannerViewWillPresentModal:)]) {
        [delegate bannerViewWillPresentModal:self];
    }
}

- (void)didDismissModal {
    // This method is called from UI-mutating code
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    self.isAdOpened = NO;
    id<PBMBannerViewDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bannerViewDidDismissModal:)]){
        [delegate bannerViewDidDismissModal:self];
    }
}

- (void)willLeaveApp {
    // This method is called as the result of UI interaction
    PBMAssertExt(NSThread.isMainThread, @"Expected to only be called on the main thread");
    id<PBMBannerViewDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bannerViewWillLeaveApplication:)]) {
        [delegate bannerViewWillLeaveApplication:self];
    }
}

- (UIViewController *)viewControllerForPresentingModal {
    return [self.delegate bannerViewPresentationController];
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

// MARK: - PBMDisplayViewInteractionDelegate

- (void)trackImpressionForDisplayView:(PBMDisplayView *)displayView {
    if ([self.eventHandler respondsToSelector:@selector(trackImpression)]) {
        [self.eventHandler trackImpression];
    }
}

- (void)displayViewWillPresentModal:(PBMDisplayView *)displayView {
    self.isAdOpened = YES;
    [self willPresentModal];
}

- (void)displayViewDidDismissModal:(PBMDisplayView *)displayView {
    self.isAdOpened = NO;
    [self didDismissModal];
}

- (UIViewController*)viewControllerForModalPresentationFrom:(PBMDisplayView *)displayView {
    return [self.delegate bannerViewPresentationController];
}

- (void)didLeaveAppFromDisplayView:(PBMDisplayView *)displayView {
    [self willLeaveApp];
}

// MARK: - PBMBannerAdLoaderDelegate

- (void)bannerAdLoader:(PBMBannerAdLoader *)bannerAdLoader createdDisplayView:(PBMDisplayView *)displayView {
    displayView.interactionDelegate = self;
}

- (void)bannerAdLoader:(PBMBannerAdLoader *)bannerAdLoader loadedAdView:(UIView *)adView adSize:(CGSize)adSize {
    [self deployView:adView];
    [self reportLoadingSuccessWithSize:adSize];
}

// MARK: - PBMAdLoadFlowControllerDelegate

- (void)adLoadFlowController:(PBMAdLoadFlowController *)adLoadFlowController failedWithError:(NSError *)error {
    [self reportLoadingFailedWithError:error];
}

- (void)adLoadFlowControllerWillSendBidRequest:(PBMAdLoadFlowController *)adLoadFlowController {
    self.isRefreshStopped = NO;
    [self.autoRefreshManager cancelRefreshTimer];
}

- (void)adLoadFlowControllerWillRequestPrimaryAd:(PBMAdLoadFlowController *)adLoadFlowController {
    [self.autoRefreshManager setupRefreshTimer];
    self.eventHandler.interactionDelegate = self;
}

- (BOOL)adLoadFlowControllerShouldContinue:(PBMAdLoadFlowController *)adLoadFlowController {
    return !self.isRefreshStopped;
}

// MARK: - Private computed properties

- (BOOL)mayRefreshNow {
    if (self.adLoadFlowController.hasFailedLoading) {
        return YES;
    }
    if (self.isAdOpened || !self.pbmIsVisible || [self isCreativeOpened]) {
        return NO;
    }
    return YES;
}

- (BOOL)isCreativeOpened {
    UIView * const deployedView = self.deployedView;
    if ([deployedView isKindOfClass:[PBMDisplayView class]]) {
        return ((PBMDisplayView *)deployedView).isCreativeOpened;
    } else {
        return NO;
    }
}

// MARK: - Private Methods

- (void)deployView:(UIView *)view {
    UIView * const oldDeployedView = self.deployedView;
    if (oldDeployedView == view) {
        return;
    }
    if (oldDeployedView) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self insertSubview:view aboveSubview:oldDeployedView];
            [oldDeployedView removeFromSuperview];
            [self installDeployedViewConstraints:view];
        });
    } else {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self addSubview:view];
            [self installDeployedViewConstraints:view];
        });
    }
    self.deployedView = view;
}

- (void)installDeployedViewConstraints:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1
                                      constant:0],
    ]];
}

- (void)reportLoadingSuccessWithSize:(CGSize)size {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        id<PBMBannerViewDelegate> const delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(bannerViewDidReceiveAd:adSize:)]) {
            [delegate bannerViewDidReceiveAd:self adSize:size];
        }
    });
}

- (void)reportLoadingFailedWithError:(nullable NSError *)error {
    if (self.deployedView) {
        UIView * const oldDeployedView = self.deployedView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [oldDeployedView removeFromSuperview];
        });
        self.deployedView = nil;
    }
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        id<PBMBannerViewDelegate> const delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(bannerView:didFailToReceiveAdWithError:)]) {
            [delegate bannerView:self didFailToReceiveAdWithError:error];
        }
    });
}

// MARK: - Static Helpers

+ (BOOL)canEventHandler:(id<PBMBannerEventHandler>)eventHandler displayAd:(nonnull PBMAdUnitConfig *)adUnitConfig {
    if (adUnitConfig.adConfiguration.adFormat != PBMAdFormatNativeInternal) {
        return YES;
    }
    if (eventHandler.isCreativeRequiredForNativeAds) {
        return (adUnitConfig.nativeAdConfig.nativeStylesCreative.length > 0);
    }
    return YES;
}

+ (BOOL)canPrebidDisplayAd:(nonnull PBMAdUnitConfig *)adUnitConfig {
    if (adUnitConfig.adConfiguration.adFormat != PBMAdFormatNativeInternal) {
        return YES;
    }
    return (adUnitConfig.nativeAdConfig.nativeStylesCreative.length > 0);
}

@end

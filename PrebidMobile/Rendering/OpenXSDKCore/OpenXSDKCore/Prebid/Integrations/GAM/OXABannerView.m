//
//  OXABannerView.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "UIView+OxmExtensions.h"

#import "OXABannerView.h"
#import "OXABannerView+InternalState.h"

#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXANativeAdConfiguration.h"
#import "OXAAdLoadFlowController.h"
#import "OXAAdLoadFlowControllerDelegate.h"
#import "OXABannerAdLoader.h"
#import "OXABannerEventInteractionDelegate.h"
#import "OXABannerEventHandler.h"
#import "OXABannerEventHandlerStandalone.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXADisplayView.h"
#import "OXADisplayView+InternalState.h"
#import "OXADisplayViewInteractionDelegate.h"
#import "OXAError.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXMAutoRefreshManager.h"
#import "OXMServerConnection.h"

#import "OXMMacros.h"

@interface OXABannerView () <OXAAdLoadFlowControllerDelegate, OXABannerEventInteractionDelegate, OXADisplayViewInteractionDelegate, OXABannerAdLoaderDelegate>

// MARK: Readonly storage
@property (nonatomic, strong, nonnull, readonly) OXMAutoRefreshManager *autoRefreshManager;
@property (nonatomic, strong, nonnull, readonly) OXAAdLoadFlowController *adLoadFlowController;

// MARK: Externally observable
@property (nonatomic, strong, nullable) UIView *deployedView;
@property (nonatomic, assign) BOOL isRefreshStopped;
@property (nonatomic, assign) BOOL isAdOpened;

// MARK: Computed helpers
@property (nonatomic, readonly) BOOL mayRefreshNow; /// whether auto-refresh is allowed to occur now
@property (nonatomic, readonly) BOOL isCreativeOpened; /// => (deployedView as? OXADisplayView).isCreativeOpened

@end


@implementation OXABannerView

@synthesize eventHandler = _eventHandler;

// MARK: - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size
                 eventHandler:(id<OXABannerEventHandler>)eventHandler
{
    if(!(self = [super initWithFrame:frame])) {
        return nil;
    }
    
    _adUnitConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configId size:size];
    _eventHandler = eventHandler;
    
    OXABannerAdLoader * const bannerAdLoader = [[OXABannerAdLoader alloc] initWithDelegate:self];
    
    _adLoadFlowController = [[OXAAdLoadFlowController alloc]
                             initWithBidRequesterFactory:^id<OXABidRequesterProtocol> (OXAAdUnitConfig * adUnitConfig) {
        return [[OXABidRequester alloc] initWithConnection:[OXMServerConnection singleton]
                                          sdkConfiguration:[OXASDKConfiguration singleton]
                                                 targeting:[OXATargeting shared]
                                       adUnitConfiguration:adUnitConfig];
    }
                             adLoader:bannerAdLoader
                             delegate:self
                             configValidationBlock:^BOOL(OXAAdUnitConfig * _Nonnull adUnitConfig, BOOL renderWithApollo)
    {
        if (renderWithApollo) {
            return [OXABannerView canApolloDisplayAd:adUnitConfig];
        } else {
            return [OXABannerView canEventHandler:eventHandler displayAd:adUnitConfig];
        }
    }];
    
    @weakify(self);
    _autoRefreshManager = [[OXMAutoRefreshManager alloc] initWithPrefetchTime:OXAAdPrefetchTime
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
                    eventHandler:(id<OXABannerEventHandler>)eventHandler {
    
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
                          eventHandler:[[OXABannerEventHandlerStandalone alloc] init]]);
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

- (OXAAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(OXAAdFormat)adFormat {
    self.adUnitConfig.adFormat = adFormat;
}

- (void)setAdPosition:(OXAAdPosition)adPosition {
    self.adUnitConfig.adPosition = adPosition;
}

- (OXAAdPosition)adPosition {
    return self.adUnitConfig.adPosition;
}

- (OXAVideoPlacementType)videoPlacementType {
    return self.adUnitConfig.videoPlacementType;
}

- (void)setVideoPlacementType:(OXAVideoPlacementType)videoPlacementType {
    self.adUnitConfig.videoPlacementType = videoPlacementType;
}

- (OXANativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

- (void)setNativeAdConfig:(OXANativeAdConfiguration *)nativeAdConfig {
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

// MARK: - OXABannerEventInteractionDelegate

- (void)willPresentModal {
    // This method is called from UI-mutating code
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    self.isAdOpened = YES;
    id<OXABannerViewDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bannerViewWillPresentModal:)]) {
        [delegate bannerViewWillPresentModal:self];
    }
}

- (void)didDismissModal {
    // This method is called from UI-mutating code
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    self.isAdOpened = NO;
    id<OXABannerViewDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bannerViewDidDismissModal:)]){
        [delegate bannerViewDidDismissModal:self];
    }
}

- (void)willLeaveApp {
    // This method is called as the result of UI interaction
    OXAAssert(NSThread.isMainThread, @"Expected to only be called on the main thread");
    id<OXABannerViewDelegate> const delegate = self.delegate;
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

// MARK: - OXADisplayViewInteractionDelegate

- (void)trackImpressionForDisplayView:(OXADisplayView *)displayView {
    if ([self.eventHandler respondsToSelector:@selector(trackImpression)]) {
        [self.eventHandler trackImpression];
    }
}

- (void)displayViewWillPresentModal:(OXADisplayView *)displayView {
    self.isAdOpened = YES;
    [self willPresentModal];
}

- (void)displayViewDidDismissModal:(OXADisplayView *)displayView {
    self.isAdOpened = NO;
    [self didDismissModal];
}

- (UIViewController*)viewControllerForModalPresentationFrom:(OXADisplayView *)displayView {
    return [self.delegate bannerViewPresentationController];
}

- (void)didLeaveAppFromDisplayView:(OXADisplayView *)displayView {
    [self willLeaveApp];
}

// MARK: - OXABannerAdLoaderDelegate

- (void)bannerAdLoader:(OXABannerAdLoader *)bannerAdLoader createdDisplayView:(OXADisplayView *)displayView {
    displayView.interactionDelegate = self;
}

- (void)bannerAdLoader:(OXABannerAdLoader *)bannerAdLoader loadedAdView:(UIView *)adView adSize:(CGSize)adSize {
    [self deployView:adView];
    [self reportLoadingSuccessWithSize:adSize];
}

// MARK: - OXAAdLoadFlowControllerDelegate

- (void)adLoadFlowController:(OXAAdLoadFlowController *)adLoadFlowController failedWithError:(NSError *)error {
    [self reportLoadingFailedWithError:error];
}

- (void)adLoadFlowControllerWillSendBidRequest:(OXAAdLoadFlowController *)adLoadFlowController {
    self.isRefreshStopped = NO;
    [self.autoRefreshManager cancelRefreshTimer];
}

- (void)adLoadFlowControllerWillRequestPrimaryAd:(OXAAdLoadFlowController *)adLoadFlowController {
    [self.autoRefreshManager setupRefreshTimer];
    self.eventHandler.interactionDelegate = self;
}

- (BOOL)adLoadFlowControllerShouldContinue:(OXAAdLoadFlowController *)adLoadFlowController {
    return !self.isRefreshStopped;
}

// MARK: - Private computed properties

- (BOOL)mayRefreshNow {
    if (self.adLoadFlowController.hasFailedLoading) {
        return YES;
    }
    if (self.isAdOpened || !self.oxaIsVisible || [self isCreativeOpened]) {
        return NO;
    }
    return YES;
}

- (BOOL)isCreativeOpened {
    UIView * const deployedView = self.deployedView;
    if ([deployedView isKindOfClass:[OXADisplayView class]]) {
        return ((OXADisplayView *)deployedView).isCreativeOpened;
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
        id<OXABannerViewDelegate> const delegate = self.delegate;
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
        id<OXABannerViewDelegate> const delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(bannerView:didFailToReceiveAdWithError:)]) {
            [delegate bannerView:self didFailToReceiveAdWithError:error];
        }
    });
}

// MARK: - Static Helpers

+ (BOOL)canEventHandler:(id<OXABannerEventHandler>)eventHandler displayAd:(nonnull OXAAdUnitConfig *)adUnitConfig {
    if (adUnitConfig.adConfiguration.adFormat != OXMAdFormatNative) {
        return YES;
    }
    if (eventHandler.isCreativeRequiredForNativeAds) {
        return (adUnitConfig.nativeAdConfig.nativeStylesCreative.length > 0);
    }
    return YES;
}

+ (BOOL)canApolloDisplayAd:(nonnull OXAAdUnitConfig *)adUnitConfig {
    if (adUnitConfig.adConfiguration.adFormat != OXMAdFormatNative) {
        return YES;
    }
    return (adUnitConfig.nativeAdConfig.nativeStylesCreative.length > 0);
}

@end

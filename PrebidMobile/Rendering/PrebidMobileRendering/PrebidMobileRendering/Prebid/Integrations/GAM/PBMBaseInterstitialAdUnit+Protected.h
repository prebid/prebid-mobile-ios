//
//  PBMBaseInterstitialAdUnit+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMBaseInterstitialAdUnit.h"

#import "PBMInterstitialEventLoadingDelegate.h"
#import "PBMRewardedEventLoadingDelegate.h"
#import "PBMInterstitialEventInteractionDelegate.h"

@class AdUnitConfig;
@class PBMBidResponse;
@class InterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMBaseInterstitialAdUnitProtocol <NSObject>

- (void)interstitialControllerDidCloseAd:(InterstitialController *)interstitialController;

- (void)callDelegate_didReceiveAd;
- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error;
- (void)callDelegate_willPresentAd;
- (void)callDelegate_didDismissAd;
- (void)callDelegate_willLeaveApplication;
- (void)callDelegate_didClickAd;

- (BOOL)callEventHandler_isReady;
- (void)callEventHandler_setLoadingDelegate:(id<PBMRewardedEventLoadingDelegate>)loadingDelegate;
- (void)callEventHandler_setInteractionDelegate;
- (void)callEventHandler_requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse;
- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller;
- (void)callEventHandler_trackImpression;

@end


@interface PBMBaseInterstitialAdUnit()  <PBMBaseInterstitialAdUnitProtocol, PBMInterstitialEventInteractionDelegate>

@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfig;
@property (nonatomic, strong, nullable, readonly) id eventHandler;

@property (nonatomic) PBMAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(id)eventHandler;

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage;

- (instancetype)initWithConfigId:(NSString *)configId
                     minSizePerc:(nullable NSValue *)minSizePerc
                    eventHandler:(nullable id)eventHandler;

@end

NS_ASSUME_NONNULL_END

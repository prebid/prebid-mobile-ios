//
//  OXABaseInterstitialAdUnit+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXABaseInterstitialAdUnit.h"

#import "OXAAdUnitConfig.h"
#import "OXAInterstitialEventLoadingDelegate.h"
#import "OXARewardedEventLoadingDelegate.h"
#import "OXAInterstitialEventInteractionDelegate.h"

@class OXABidResponse;
@class OXAInterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol OXABaseInterstitialAdUnitProtocol <NSObject>

- (void)interstitialControllerDidCloseAd:(OXAInterstitialController *)interstitialController;

- (void)callDelegate_didReceiveAd;
- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error;
- (void)callDelegate_willPresentAd;
- (void)callDelegate_didDismissAd;
- (void)callDelegate_willLeaveApplication;
- (void)callDelegate_didClickAd;

- (BOOL)callEventHandler_isReady;
- (void)callEventHandler_setLoadingDelegate:(id<OXARewardedEventLoadingDelegate>)loadingDelegate;
- (void)callEventHandler_setInteractionDelegate;
- (void)callEventHandler_requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse;
- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller;
- (void)callEventHandler_trackImpression;

@end


@interface OXABaseInterstitialAdUnit<__covariant EventHandlerType, __covariant DelegateType> ()  <OXABaseInterstitialAdUnitProtocol, OXAInterstitialEventInteractionDelegate>

@property (nonatomic, strong, nonnull, readonly) OXAAdUnitConfig *adUnitConfig;
@property (nonatomic, strong, nullable, readonly) EventHandlerType eventHandler;

@property (nonatomic) OXAAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(EventHandlerType)eventHandler;

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage;

- (instancetype)initWithConfigId:(NSString *)configId
                     minSizePerc:(nullable NSValue *)minSizePerc
                    eventHandler:(nullable EventHandlerType)eventHandler;

@end

NS_ASSUME_NONNULL_END

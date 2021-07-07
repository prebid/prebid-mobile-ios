//
//  MPAdAdapterDelegate.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdEvent.h"
#import "MPAdView.h"
#import "MPMediationSettingsProtocol.h"
#import "MPReward.h"

@protocol MPAdAdapter;

NS_ASSUME_NONNULL_BEGIN

@protocol MPAdAdapterBaseDelegate <NSObject>

- (void)adapter:(id<MPAdAdapter> _Nullable)adapter didFailToLoadAdWithError:(NSError * _Nullable)error;
- (void)adapter:(id<MPAdAdapter> _Nullable)adapter didFailToPlayAdWithError:(NSError *)error;
- (void)adDidReceiveImpressionEventForAdapter:(id<MPAdAdapter>)adapter;

@end

#pragma mark - Inline

@protocol MPAdAdapterInlineEventDelegate <MPAdAdapterBaseDelegate>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)inlineAdAdapter:(id<MPAdAdapter>)adapter didLoadAdWithAdView:(UIView *)adView;
- (void)adAdapter:(id<MPAdAdapter>)adapter handleInlineAdEvent:(MPInlineAdEvent)inlineAdEvent;

@end

#pragma mark - Fullscreen

@protocol MPAdAdapterFullscreenEventDelegate <MPAdAdapterBaseDelegate>

- (void)adAdapter:(id<MPAdAdapter>)adapter handleFullscreenAdEvent:(MPFullscreenAdEvent)fullscreenAdEvent;

@end

#pragma mark - Rewarded

@protocol MPAdAdapterRewardEventDelegate <MPAdAdapterBaseDelegate>

- (NSString * _Nullable)customerId;

- (id<MPMediationSettingsProtocol> _Nullable)instanceMediationSettingsForClass:(Class)aClass;
- (void)adShouldRewardUserForAdapter:(id<MPAdAdapter>)adapter reward:(MPReward *)reward;

@end

#pragma mark - Complete

@protocol MPAdAdapterCompleteDelegate <
    MPAdAdapterBaseDelegate,
    MPAdAdapterInlineEventDelegate,
    MPAdAdapterFullscreenEventDelegate,
    MPAdAdapterRewardEventDelegate
>
@end

NS_ASSUME_NONNULL_END

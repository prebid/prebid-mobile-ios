//
//  OXARewardedAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class OXARewardedAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the OXARewardedAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol OXARewardedAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)rewardedAdDidReceiveAd:(OXARewardedAdUnit *)rewardedAd;

/// Called when user is able to receive a reward from the app
- (void)rewardedAdUserDidEarnReward:(OXARewardedAdUnit *)rewardedAd;

/// Called when the load process fails to produce a viable ad
- (void)rewardedAd:(OXARewardedAdUnit *)rewardedAd
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)rewardedAdWillPresentAd:(OXARewardedAdUnit *)rewardedAd;

/// Called when the interstial is dismissed by the user
- (void)rewardedAdDidDismissAd:(OXARewardedAdUnit *)rewardedAd;

/// Called when an ad causes the sdk to leave the app
- (void)rewardedAdWillLeaveApplication:(OXARewardedAdUnit *)rewardedAd;

/// Called when user clicked the ad
- (void)rewardedAdDidClickAd:(OXARewardedAdUnit *)rewardedAd;

@end

NS_ASSUME_NONNULL_END

//
//  PBMRewardedAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class RewardedAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the PBMRewardedAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol PBMRewardedAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)rewardedAdDidReceiveAd:(RewardedAdUnit *)rewardedAd;

/// Called when user is able to receive a reward from the app
- (void)rewardedAdUserDidEarnReward:(RewardedAdUnit *)rewardedAd;

/// Called when the load process fails to produce a viable ad
- (void)rewardedAd:(RewardedAdUnit *)rewardedAd
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)rewardedAdWillPresentAd:(RewardedAdUnit *)rewardedAd;

/// Called when the interstial is dismissed by the user
- (void)rewardedAdDidDismissAd:(RewardedAdUnit *)rewardedAd;

/// Called when an ad causes the sdk to leave the app
- (void)rewardedAdWillLeaveApplication:(RewardedAdUnit *)rewardedAd;

/// Called when user clicked the ad
- (void)rewardedAdDidClickAd:(RewardedAdUnit *)rewardedAd;

@end

NS_ASSUME_NONNULL_END

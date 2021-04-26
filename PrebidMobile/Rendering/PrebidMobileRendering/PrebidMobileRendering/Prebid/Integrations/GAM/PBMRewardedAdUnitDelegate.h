//
//  PBMRewardedAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class PBMRewardedAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the PBMRewardedAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol PBMRewardedAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)rewardedAdDidReceiveAd:(PBMRewardedAdUnit *)rewardedAd;

/// Called when user is able to receive a reward from the app
- (void)rewardedAdUserDidEarnReward:(PBMRewardedAdUnit *)rewardedAd;

/// Called when the load process fails to produce a viable ad
- (void)rewardedAd:(PBMRewardedAdUnit *)rewardedAd
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)rewardedAdWillPresentAd:(PBMRewardedAdUnit *)rewardedAd;

/// Called when the interstial is dismissed by the user
- (void)rewardedAdDidDismissAd:(PBMRewardedAdUnit *)rewardedAd;

/// Called when an ad causes the sdk to leave the app
- (void)rewardedAdWillLeaveApplication:(PBMRewardedAdUnit *)rewardedAd;

/// Called when user clicked the ad
- (void)rewardedAdDidClickAd:(PBMRewardedAdUnit *)rewardedAd;

@end

NS_ASSUME_NONNULL_END

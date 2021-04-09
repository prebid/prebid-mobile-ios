//
//  MPFullscreenAdAdapter+Reward.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter (Reward)

/**
 For rewarded ads, this is the countdown duration before the Skip or Close button is shown.
 */
- (NSTimeInterval)rewardCountdownDuration;

/**
 Reward the user at most once after the reward countdown duration, or after user interaction if
 `rewardedPlayableShouldRewardOnClick` is YES.
 
 Note: This method is the centralized location for reward validation business logic. All code paths
 in @c MPFullscreenAdAdapter that provide a reward to the user must pass through this method.
 */
- (void)provideRewardToUser:(MPReward *)reward
 forRewardCountdownComplete:(BOOL)isForRewardCountdownComplete
            forUserInteract:(BOOL)isForUserInteract;

@end

NS_ASSUME_NONNULL_END

//
//  MPFullscreenAdAdapter+Reward.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewConstant.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPLogging.h"
#import "MPRewardedAds+Internal.h"

@implementation MPFullscreenAdAdapter (Reward)

- (NSTimeInterval)rewardCountdownDuration {
    NSTimeInterval duration = self.configuration.rewardedDuration;
    if (self.configuration.hasValidRewardFromMoPubSDK && duration <= 0) {
        duration = kDefaultRewardCountdownTimerIntervalInSeconds;
    }

    return duration;
}

- (void)provideRewardToUser:(MPReward *)reward
 forRewardCountdownComplete:(BOOL)isForRewardCountdownComplete
            forUserInteract:(BOOL)isForUserInteract {
    // Only provide a reward to the user if a reward is expected so non-rewarded ads don't receive reward callbacks.
    // Note: checking the adapter instance's own @c isRewardExpected getter allows us to use information
    // provided by the network's adapter, whereas using @c MPAdConfiguration's @c isRewarded only uses
    // information from our ad server.
    if (!self.isRewardExpected) {
        return;
    }

    // Note: Do not hold back the reward if `isRewardExpected` is NO, because it's possible that
    // the rewarded is not defined in the ad response / ad configuration, but is defined after
    // the reward condition has been satisfied (for 3rd party ad SDK's).

    if (!isForRewardCountdownComplete) {
        // Do not reward the user until the reward countdown is complete.
        return;
    }

    if (self.isUserRewarded) {
        return;
    }
    self.isUserRewarded = YES;

    // Server side reward tracking:
    // The original URLs come from the value of "x-rewarded-video-completion-url" in ad response.
    NSArray<NSURL *> * urls = self.rewardedVideoCompletionUrlsByAppendingClientParams;
    for (NSURL * url in urls) {
        [[MPRewardedAds sharedInstance] startRewardedAdConnectionWithUrl:url];
    }

    // Client side reward handling:
    // Preference is given to the rewards from `MPAdConfiguration` if any are available.
    // Otherwise, use the reward given to us by the adapter.
    MPReward *mopubConfiguredReward = self.configuration.selectedReward;
    if (mopubConfiguredReward != nil && mopubConfiguredReward.isCurrencyTypeSpecified) {
        reward = mopubConfiguredReward;
    }

    MPLogInfo(@"MoPub user should be rewarded: %@", reward.debugDescription);
    if ([self.adapterDelegate respondsToSelector:@selector(adShouldRewardUserForAdapter:reward:)]) {
        [self.adapterDelegate adShouldRewardUserForAdapter:self reward:reward];;
    }
}

@end

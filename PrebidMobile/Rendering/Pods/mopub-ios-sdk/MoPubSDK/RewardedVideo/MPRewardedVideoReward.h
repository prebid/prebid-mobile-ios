//
//  MPRewardedVideoReward.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPReward.h"

/**
 A constant that indicates that no currency type was specified with the reward.
 */
extern NSString *const kMPRewardedVideoRewardCurrencyTypeUnspecified __deprecated_msg("Use `kMPRewardCurrencyTypeUnspecified` instead.");

/**
 A constant that indicates that no currency amount was specified with the reward.
 */
extern NSInteger const kMPRewardedVideoRewardCurrencyAmountUnspecified __deprecated_msg("Use `kMPRewardCurrencyAmountUnspecified` instead.");

/**
 @c MPRewardedVideoReward is about to be deprecated after the public API @c MPRewardedVideo is
 updated to use @c MPReward instead. Internally in the SDK, use Use `MPReward` instead.

 `MPRewardedVideoReward` contains all the information needed to reward the user for watching
 a rewarded video ad. The class provides a currency amount and currency type.
 */
@interface MPRewardedVideoReward : MPReward

+ (MPRewardedVideoReward *)rewardWithReward:(MPReward *)reward;

@end

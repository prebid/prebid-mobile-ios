//
//  MPRewardedVideoReward.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPReward.h"

/**
 A constant that indicates that no currency type was specified with the reward.
 @deprecated This API is deprecated and will be removed in a future version.
 */
extern NSString *const kMPRewardedVideoRewardCurrencyTypeUnspecified DEPRECATED_MSG_ATTRIBUTE("Use `kMPRewardCurrencyTypeUnspecified` instead.");

/**
 A constant that indicates that no currency amount was specified with the reward.
 @deprecated This API is deprecated and will be removed in a future version.
 */
extern NSInteger const kMPRewardedVideoRewardCurrencyAmountUnspecified DEPRECATED_MSG_ATTRIBUTE("Use `kMPRewardCurrencyAmountUnspecified` instead.");

/**
 @c MPRewardedVideoReward is deprecated. Please use @c MPReward instead.
 */
DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoReward is deprecated. Please use MPReward instead.")
@interface MPRewardedVideoReward : MPReward

+ (MPRewardedVideoReward *)rewardWithReward:(MPReward *)reward DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoReward is deprecated. Please use MPReward instead.");

@end

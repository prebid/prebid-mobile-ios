//
//  MPRewardedVideoReward.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoReward.h"

NSString *const kMPRewardedVideoRewardCurrencyTypeUnspecified = @"MPMoPubRewardedVideoRewardCurrencyTypeUnspecified";
NSInteger const kMPRewardedVideoRewardCurrencyAmountUnspecified = 0;

@implementation MPRewardedVideoReward

+ (MPRewardedVideoReward *)rewardWithReward:(MPReward *)reward {
    if (reward == nil) {
        return nil; // watch out for unit test failure is this case is removed
    }
    else {
        return [[MPRewardedVideoReward alloc] initWithCurrencyType:reward.currencyType amount:reward.amount];
    }
}

@end

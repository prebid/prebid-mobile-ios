//
//  MPRewardedVideoReward.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoReward.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
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
#pragma clang pop

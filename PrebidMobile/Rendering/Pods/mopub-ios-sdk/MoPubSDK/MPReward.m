//
//  MPReward.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPReward.h"

/*
 The value has the "RewardedVideo" word in it for historic reasons. Remove "RewardedVideo" after
 @c kMPRewardCurrencyTypeUnspecified is removed and unsupported.
 */
NSString *const kMPRewardCurrencyTypeUnspecified = @"MPMoPubRewardedVideoRewardCurrencyTypeUnspecified";

NSInteger const kMPRewardCurrencyAmountUnspecified = 0;

@implementation MPReward

- (instancetype)initWithCurrencyType:(NSString *)currencyType amount:(NSNumber *)amount
{
    if (self = [super init]) {
        _currencyType = currencyType;
        _amount = amount;
    }

    return self;
}

- (instancetype)initWithCurrencyAmount:(NSNumber *)amount
{
    return [self initWithCurrencyType:kMPRewardCurrencyTypeUnspecified amount:amount];
}

- (instancetype)init
{
    return MPReward.unspecifiedReward;
}

+ (instancetype)unspecifiedReward {
    return [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified
                                            amount:@(kMPRewardCurrencyAmountUnspecified)];
}

- (BOOL)isCurrencyTypeSpecified {
    return NO == [self.currencyType isEqualToString:kMPRewardCurrencyTypeUnspecified];
}

// Need to implement both `isEqual:` and `hash` for `MPReward` VS `MPRewardedVideoReward` equality check.
- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if ([other isKindOfClass:MPReward.class]) {
        MPReward *otherReward = (MPReward *)other;
        return ([self.currencyType isEqualToString:otherReward.currencyType]
                && [self.amount isEqualToNumber:otherReward.amount]);
    } else {
        return NO;
    }
}

// Need to implement both `isEqual:` and `hash` for `MPReward` VS `MPRewardedVideoReward` equality check.
- (NSUInteger)hash
{
    return self.currencyType.hash ^ self.amount.hash;
}

- (NSString *)description {
    NSString *message = nil;
    if (self.amount != nil && self.currencyType != nil) {
        message = [NSString stringWithFormat:@"%@ %@", self.amount, self.currencyType];
    }
    return message;
}

@end

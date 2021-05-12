//
//  MPReward.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

/// A constant that indicates that no currency type was specified with the reward.
extern NSString *const kMPRewardCurrencyTypeUnspecified;

/// A constant that indicates that no currency amount was specified with the reward.
extern NSInteger const kMPRewardCurrencyAmountUnspecified;

/**
 `MPReward` contains all the information needed to reward the user for playing a rewarded ad. The
 class provides a currency amount and currency type.
 */
@interface MPReward : NSObject

/**
 The type of currency that should be rewarded to the user.
 
 An undefined currency type should be specified as `kMPRewardCurrencyTypeUnspecified`.
 */
@property (nonatomic, readonly) NSString *currencyType;

/**
 The amount of currency to reward to the user.
 
 An undefined currency amount should be specified as `kMPRewardCurrencyAmountUnspecified` wrapped as
 an NSNumber.
 */
@property (nonatomic, readonly) NSNumber *amount;

/**
 Initialize with an undefined currency type @c kMPRewardCurrencyTypeUnspecified and the provided amount.
 
 @param amount The amount of currency the user is receiving.
 */
- (instancetype)initWithCurrencyAmount:(NSNumber *)amount;

/**
 Initialize with @c the currencyType and @c amount.
 
 @param currencyType The type of currency the user is receiving.
 @param amount The amount of currency the user is receiving.
 */
- (instancetype)initWithCurrencyType:(NSString *)currencyType amount:(NSNumber *)amount;

/**
 Return a reward with type @c kMPRewardCurrencyTypeUnspecified and amout @c kMPRewardCurrencyAmountUnspecified.
 Typically this "unspecified reward" is a placehold object that represents an expected but unknown reward.
 */
+ (instancetype)unspecifiedReward;

/**
 A helper for comparing @c currencyType against @c kMPRewardCurrencyTypeUnspecified.
 */
- (BOOL)isCurrencyTypeSpecified;

@end

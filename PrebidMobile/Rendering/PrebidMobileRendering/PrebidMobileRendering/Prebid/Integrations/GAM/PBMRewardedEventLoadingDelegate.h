//
//  PBMRewardedEventLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PBMInterstitialEventLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 The rewarded custom event delegate. It is used to inform ad server events back to the OpenWrap SDK
 */
@protocol PBMRewardedEventLoadingDelegate <PBMInterstitialEventLoadingDelegate>

/*!
 @abstract The reward to be given to the user. May be assigned on successful loading.
 */
@property (nonatomic, strong, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END

//
//  PBMRewardedAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBMBaseInterstitialAdUnit.h"

#import "PBMRewardedAdUnitDelegate.h"

@protocol PBMRewardedEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface PBMRewardedAdUnit : PBMBaseInterstitialAdUnit<id<PBMRewardedEventHandler>, id<PBMRewardedAdUnitDelegate> >

@property (nonatomic, readonly, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END

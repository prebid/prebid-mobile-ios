//
//  OXARewardedAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OXABaseInterstitialAdUnit.h"

#import "OXARewardedAdUnitDelegate.h"

@protocol OXARewardedEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface OXARewardedAdUnit : OXABaseInterstitialAdUnit<id<OXARewardedEventHandler>, id<OXARewardedAdUnitDelegate> >

@property (nonatomic, readonly, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END

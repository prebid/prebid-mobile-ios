//
//  OXARewardedAdUnit+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "OXARewardedAdUnit.h"
#import "OXARewardedEventLoadingDelegate.h"
#import "OXARewardedEventInteractionDelegate.h"



@interface OXARewardedAdUnit () <OXARewardedEventInteractionDelegate>

@property (nonatomic, strong, readwrite, nullable) NSObject *reward;

- (void)callDelegate_rewardedAdUserDidEarnReward;

@end

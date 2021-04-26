//
//  PBMRewardedAdUnit+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "PBMRewardedAdUnit.h"
#import "PBMRewardedEventLoadingDelegate.h"
#import "PBMRewardedEventInteractionDelegate.h"



@interface PBMRewardedAdUnit () <PBMRewardedEventInteractionDelegate>

@property (nonatomic, strong, readwrite, nullable) NSObject *reward;

- (void)callDelegate_rewardedAdUserDidEarnReward;

@end

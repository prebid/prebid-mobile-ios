/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "GAMDisplayRewardedViewController.h"

NSString * const storedImpGAMDisplayRewarded = @"prebid-demo-banner-rewarded-time";
NSString * const gamAdUnitDisplayRewardedRendering = @"/21808260008/prebid_oxb_rewarded_video_test";

@interface GAMDisplayRewardedViewController ()

// Prebid
@property (nonatomic) RewardedAdUnit * rewardedAdUnit;

@end

@implementation GAMDisplayRewardedViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GAMRewardedAdEventHandler
    GAMRewardedAdEventHandler * eventHandler = [[GAMRewardedAdEventHandler alloc] initWithAdUnitID:gamAdUnitDisplayRewardedRendering];
    
    // 2. Create a RewardedAdUnit
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:storedImpGAMDisplayRewarded eventHandler:eventHandler];
    self.rewardedAdUnit.delegate = self;
    
    // 3. Load the rewarded ad
    [self.rewardedAdUnit loadAd];
}

// MARK: - RewardedAdUnitDelegate

- (void)rewardedAdDidReceiveAd:(RewardedAdUnit *)rewardedAd {
    if (rewardedAd.isReady) {
        [rewardedAd showFrom:self];
    }
}

- (void)rewardedAd:(RewardedAdUnit *)rewardedAd didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

- (void)rewardedAdUserDidEarnReward:(RewardedAdUnit *)rewardedAd reward:(PrebidReward *)reward {
    NSLog(@"User did earn reward - type: %@, count: %f", reward.type, [reward.count doubleValue]);
}

@end

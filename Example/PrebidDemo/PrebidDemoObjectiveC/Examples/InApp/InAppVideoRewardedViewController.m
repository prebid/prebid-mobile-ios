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

#import "InAppVideoRewardedViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoRewardedInApp = @"prebid-demo-video-rewarded-endcard-time";

@interface InAppVideoRewardedViewController ()

// Prebid
@property (nonatomic) RewardedAdUnit * rewardedAdUnit;

@end

@implementation InAppVideoRewardedViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a RewardedAdUnit
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:storedImpVideoRewardedInApp];
    self.rewardedAdUnit.delegate = self;
    
    // 2. Load the rewarded ad
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

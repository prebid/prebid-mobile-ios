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

#import "GAMVideoRewardedViewController.h"

NSString * const storedImpGAMVideoRewarded = @"imp-prebid-video-rewarded-320-480";
NSString * const storedResponseGAMVideoRewarded = @"response-prebid-video-rewarded-320-480";
NSString * const gamAdUnitVideoRewardedRendering = @"/21808260008/prebid_oxb_rewarded_video_test";

@interface GAMVideoRewardedViewController ()

// Prebid
@property (nonatomic) RewardedAdUnit * rewardedAdUnit;

@end

@implementation GAMVideoRewardedViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseGAMVideoRewarded;
    [self createAd];
}

- (void)createAd {
    // 1. Create a GAMRewardedAdEventHandler
    GAMRewardedAdEventHandler * eventHandler = [[GAMRewardedAdEventHandler alloc] initWithAdUnitID:gamAdUnitVideoRewardedRendering];
    
    // 2. Create a RewardedAdUnit
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:storedImpGAMVideoRewarded eventHandler:eventHandler];
    self.rewardedAdUnit.delegate = self;
    
    // 3. Load the rewarded ad
    [self.rewardedAdUnit loadAd];
}

// MARK: - RewardedAdUnitDelegate

- (void)rewardedAdDidReceiveAd:(RewardedAdUnit *)rewardedAd {
    [self.rewardedAdUnit showFrom:self];
}

- (void)rewardedAd:(RewardedAdUnit *)rewardedAd didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

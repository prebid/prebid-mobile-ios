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

#import "GAMOriginalAPIVideoRewardedViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const storedResponseVideoRewarded = @"response-prebid-video-rewarded-320-480-original-api";
NSString * const storedImpVideoRewarded = @"imp-prebid-video-rewarded-320-480";
NSString * const gamAdUnitVideoRewardedOriginal = @"/21808260008/prebid-demo-app-original-api-video-interstitial";

@interface GAMOriginalAPIVideoRewardedViewController ()

// Prebid
@property (nonatomic) RewardedVideoAdUnit * adUnit;

@end

@implementation GAMOriginalAPIVideoRewardedViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseVideoRewarded;
    [self createAd];
}

- (void)createAd {
    // 1. Create a RewardedVideoAdUnit
    self.adUnit = [[RewardedVideoAdUnit alloc] initWithConfigId:storedImpVideoRewarded];
    
    // 2. Configure video parameters
    VideoParameters * parameters = [[VideoParameters alloc] init];
    parameters.mimes = @[@"video/mp4"];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    self.adUnit.parameters = parameters;
    
    // 3. Make a bid request to Prebid Server
    GAMRequest * gamRequest = [GAMRequest new];
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        
        // 4. Load the GAM rewarded ad
        [GADRewardedAd loadWithAdUnitID:gamAdUnitVideoRewardedOriginal request:gamRequest completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (rewardedAd != nil) {
                // 5. Present the interstitial ad
                rewardedAd.fullScreenContentDelegate = self;
                [rewardedAd presentFromRootViewController:self userDidEarnRewardHandler:^{
                    
                }];
            }
        }];
    }];   
}

// MARK: - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

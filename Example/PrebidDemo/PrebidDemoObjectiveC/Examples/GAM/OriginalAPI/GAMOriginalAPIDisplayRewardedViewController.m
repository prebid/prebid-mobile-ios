/*   Copyright 2019-2026 Prebid.org, Inc.
 
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

#import "GAMOriginalAPIDisplayRewardedViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const storedImpDisplayRewardedOriginal = @"prebid-demo-banner-rewarded-time";
NSString * const gamAdUnitDisplayRewardedOriginal = @"/21808260008/prebid-demo-app-original-api-display-interstitial";

@interface GAMOriginalAPIDisplayRewardedViewController ()

@property (nonatomic) RewardedDisplayAdUnit * adUnit;

@end

@implementation GAMOriginalAPIDisplayRewardedViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a RewardedDisplayAdUnit
    self.adUnit = [[RewardedDisplayAdUnit alloc] initWithConfigId:storedImpDisplayRewardedOriginal];
    
    // 2. Configure banner parameters
    BannerParameters * bannerParameters = [BannerParameters new];
    bannerParameters.api = @[PBApi.MRAID_2];
    [bannerParameters setAdSizes:@[[NSValue valueWithCGSize:CGSizeMake(320, 480)]]];
    self.adUnit.bannerParameters = bannerParameters;
    
    // 3. Make a bid request to Prebid Server
    GAMRequest * gamRequest = [GAMRequest new];
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 4. Load the GAM rewarded ad
        @weakify(self);
        [GADRewardedAd loadWithAdUnitID:gamAdUnitDisplayRewardedOriginal request:gamRequest completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            @strongify(self);
            if (!self) { return; }
            
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (rewardedAd != nil) {
                // 5. Present the rewarded ad
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

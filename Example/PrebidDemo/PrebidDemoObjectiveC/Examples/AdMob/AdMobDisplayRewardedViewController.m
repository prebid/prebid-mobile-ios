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

#import "AdMobDisplayRewardedViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpDisplayRewardedAdMob = @"prebid-demo-banner-rewarded-time";
NSString * const adMobAdUnitDisplayRewardedId = @"ca-app-pub-5922967660082475/5628505938";

@interface AdMobDisplayRewardedViewController ()

// Prebid
@property (nonatomic) MediationRewardedAdUnit * admobRewardedAdUnit;
@property (nonatomic) AdMobMediationRewardedUtils * mediationDelegate;

// AdMob
@property (nonatomic) GADRewardedAd * gadRewardedAd;

@end

@implementation AdMobDisplayRewardedViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GADRequest
    GADRequest * gadRequest = [GADRequest new];
    
    // 2. Create an AdMobMediationRewardedUtils
    self.mediationDelegate = [[AdMobMediationRewardedUtils alloc] initWithGadRequest:gadRequest];
    
    // 3. Create a MediationRewardedAdUnit
    self.admobRewardedAdUnit = [[MediationRewardedAdUnit alloc] initWithConfigId:storedImpDisplayRewardedAdMob
                                                               mediationDelegate:self.mediationDelegate];
    
    // 4. Make a bid request to Prebid Server
    @weakify(self);
    [self.admobRewardedAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        
        // 5. Load the rewarded ad
        @weakify(self);
        [GADRewardedAd loadWithAdUnitID:adMobAdUnitDisplayRewardedId
                                request:gadRequest
                      completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            @strongify(self);
            if (!self) { return; }
            
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
                return;
            }
            
            // 6. Present the rewarded ad
            if (rewardedAd != nil) {
                self.gadRewardedAd = rewardedAd;
                self.gadRewardedAd.fullScreenContentDelegate = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.gadRewardedAd presentFromRootViewController:self userDidEarnRewardHandler:^{
                        NSLog(@"User did earn reward.");
                    }];
                });
            }
        }];
    }];
}

// MARK: - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

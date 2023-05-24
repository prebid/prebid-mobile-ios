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

#import "GAMOriginalAPIDisplayInterstitialViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const storedImpDisplayInterstitial = @"prebid-demo-display-interstitial-320-480";
NSString * const gamAdUnitDisplayInterstitialOriginal = @"/21808260008/prebid-demo-app-original-api-display-interstitial";

@interface GAMOriginalAPIDisplayInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialAdUnit * adUnit;

@end

@implementation GAMOriginalAPIDisplayInterstitialViewController


- (void)loadView {
    [super loadView];
    
    [self createAd];
}

-(void)createAd {
    // 1. Create an InterstitialAdUnit
    self.adUnit = [[InterstitialAdUnit alloc] initWithConfigId:storedImpDisplayInterstitial];
    
    // 2. Make a bid request to Prebid Server
    GAMRequest * gamRequest = [GAMRequest new];
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 3. Load a GAM interstitial ad
        @weakify(self);
        [GAMInterstitialAd loadWithAdManagerAdUnitID:gamAdUnitDisplayInterstitialOriginal request:gamRequest completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            @strongify(self);
            if (!self) { return; }
           
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (interstitialAd != nil) {
                // 4. Present the interstitial ad
                interstitialAd.fullScreenContentDelegate = self;
                [interstitialAd presentFromRootViewController:self];
            }
        }];
    }];
}

// MARK: - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

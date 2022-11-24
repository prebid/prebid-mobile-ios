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

NSString * const storedResponseDisplayInterstitial = @"response-prebid-display-interstitial-320-480";
NSString * const storedImpDisplayInterstitial = @"imp-prebid-display-interstitial-320-480";
NSString * const gamAdUnitDisplayInterstitialOriginal = @"/21808260008/prebid-demo-app-original-api-display-interstitial";

@interface GAMOriginalAPIDisplayInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialAdUnit * adUnit;

// GAM
@property (nonatomic) GAMRequest * gamRequest;

@end

@implementation GAMOriginalAPIDisplayInterstitialViewController


- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseDisplayInterstitial;
    [self createAd];
}

-(void)createAd {
    // Setup Prebid ad unit
    self.adUnit = [[InterstitialAdUnit alloc] initWithConfigId:storedImpDisplayInterstitial];
    
    // Setup integration kind - GAM
    self.gamRequest = [GAMRequest new];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:self.gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        [GAMInterstitialAd loadWithAdManagerAdUnitID:gamAdUnitDisplayInterstitialOriginal request:self.gamRequest completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
           
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (interstitialAd != nil) {
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

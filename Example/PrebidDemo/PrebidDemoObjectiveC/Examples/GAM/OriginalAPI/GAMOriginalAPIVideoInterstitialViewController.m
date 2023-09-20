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

#import "GAMOriginalAPIVideoInterstitialViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const storedImpVideoInterstitial = @"prebid-demo-video-interstitial-320-480-original-api";
NSString * const gamAdUnitVideoInterstitialOriginal = @"/21808260008/prebid-demo-app-original-api-video-interstitial";

@interface GAMOriginalAPIVideoInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialAdUnit * adUnit;

@end

@implementation GAMOriginalAPIVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create an InterstitialAdUnit
    self.adUnit = [[InterstitialAdUnit alloc] initWithConfigId:storedImpVideoInterstitial];
    
    // 2. Set ad format
    self.adUnit.adFormats = [NSSet setWithObject:AdFormat.banner];
    
    // 3. Configure video parameters
    VideoParameters * parameters = [[VideoParameters alloc] initWithMimes:@[@"video/mp4"]];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    self.adUnit.videoParameters = parameters;
    
    // 4. Make a bid request to Prebid Server
    GAMRequest * gamRequest = [GAMRequest new];
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 5. Load a GAM interstitial ad
        @weakify(self);
        [GAMInterstitialAd loadWithAdManagerAdUnitID:gamAdUnitVideoInterstitialOriginal request:gamRequest completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            @strongify(self);
            if (!self) { return; }
            
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (interstitialAd != nil) {
                // 6. Present the interstitial ad
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

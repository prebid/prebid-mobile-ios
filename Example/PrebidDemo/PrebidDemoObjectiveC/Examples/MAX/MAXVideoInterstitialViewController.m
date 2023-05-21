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

#import "MAXVideoInterstitialViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoInterstitialMAX = @"prebid-demo-video-interstitial-320-480";
NSString * const maxAdUnitVideoInterstitial = @"48e8d410f74dfc7b";

@interface MAXVideoInterstitialViewController ()

// Prebid
@property (nonatomic) MediationInterstitialAdUnit * maxAdUnit;
@property (nonatomic) MAXMediationInterstitialUtils * maxMediationDelegate;

// MAX
@property (nonatomic) MAInterstitialAd * maxInterstitial;

@end

@implementation MAXVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a MAInterstitialAd
    self.maxInterstitial = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:maxAdUnitVideoInterstitial];
    
    // 2. Create a MAXMediationInterstitialUtils
    self.maxMediationDelegate = [[MAXMediationInterstitialUtils alloc] initWithInterstitialAd:self.maxInterstitial];
    
    // 3. Create a MediationInterstitialAdUnit
    self.maxAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:storedImpVideoInterstitialMAX mediationDelegate:self.maxMediationDelegate];
    self.maxAdUnit.adFormats = [[NSSet alloc] initWithObjects:AdFormat.video, nil];
    
    // 4. Make a bid request to Prebid Server
    @weakify(self);
    [self.maxAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self); 
        if (!self) { return; }
        
        // 5. Load the interstitial ad
        self.maxInterstitial.delegate = self;
        [self.maxInterstitial loadAd];
    }];
}

// MARK: - MAAdDelegate

- (void)didLoadAd:(MAAd *)ad {
    if (self.maxInterstitial != nil && self.maxInterstitial.isReady) {
        [self.maxInterstitial showAd];
    }
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    PBMLogError(@"%@", error.message);
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    PBMLogError(@"%@", error.message);
}

- (void)didDisplayAd:(MAAd *)ad {
}

- (void)didHideAd:(MAAd *)ad {
}

- (void)didClickAd:(MAAd *)ad {
}

@end

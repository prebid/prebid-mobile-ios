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

#import "MAXDisplayInterstitialViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedResponseDisplayInterstitialMAX = @"response-prebid-display-interstitial-320-480";
NSString * const storedImpDisplayInterstitialMAX = @"imp-prebid-display-interstitial-320-480";
NSString * const maxAdUnitDisplayInterstitial = @"48e8d410f74dfc7b";

@interface MAXDisplayInterstitialViewController ()

// Prebid
@property (nonatomic) MediationInterstitialAdUnit * maxAdUnit;
@property (nonatomic) MAXMediationInterstitialUtils * maxMediationDelegate;

// MAX
@property (nonatomic) MAInterstitialAd * maxInterstitial;

@end

@implementation MAXDisplayInterstitialViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseDisplayInterstitialMAX;
    [self createAd];
}

- (void)createAd {
    // Setup integration kind - AppLovin MAX
    self.maxInterstitial = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:maxAdUnitDisplayInterstitial];
    
    // Setup Prebid mediation ad unit
    self.maxMediationDelegate = [[MAXMediationInterstitialUtils alloc] initWithInterstitialAd:self.maxInterstitial];
    self.maxAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:storedImpDisplayInterstitialMAX mediationDelegate:self.maxMediationDelegate];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
    @weakify(self);
    [self.maxAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
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

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

#import "GAMOriginalAPIDisplayBannerViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;
@import GoogleMobileAds;

NSString * const storedImpDisplayBanner = @"prebid-demo-banner-320-50";
NSString * const gamAdUnitDisplayBannerOriginal = @"/21808260008/prebid_demo_app_original_api_banner";

@interface GAMOriginalAPIDisplayBannerViewController ()

// Prebid
@property (nonatomic) BannerAdUnit *adUnit;

// GAM
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMOriginalAPIDisplayBannerViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)dealloc {
    // Clean up global ORTB config
    [Targeting.shared setGlobalORTBConfig:nil];
}

- (void)createAd {
    // 1. Set global ORTB
    NSString *globalORTB = [NSString stringWithFormat:
        @"{"
            "\"ext\": {"
                "\"myext\": {"
                    "\"test\": 1"
                "}"
            "},"
            "\"displaymanager\": \"Google\","
            "\"displaymanagerver\": \"%@\""
        "}",
        GADGetStringFromVersionNumber([GADMobileAds sharedInstance].versionNumber)
    ];
    
    [Targeting.shared setGlobalORTBConfig:globalORTB];
    
    // 2. Create a BannerAdUnit
    self.adUnit = [[BannerAdUnit alloc] initWithConfigId:storedImpDisplayBanner size:self.adSize];
    
    // 3. Configure banner parameters
    BannerParameters * parameters = [[BannerParameters alloc] init];
    parameters.api = @[PBApi.MRAID_2];
    self.adUnit.bannerParameters = parameters;
    
    // 4. Set impression-level ORTB
    [self.adUnit setImpORTBConfig:@"{\"bidfloor\":0.01,\"banner\":{\"battr\":[1,2,3,4]}}"];
    
    // 5. Create a GAMBannerView
    GAMRequest * gamRequest = [GAMRequest new];
    self.gamBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gamBanner.adUnitID = gamAdUnitDisplayBannerOriginal;
    self.gamBanner.rootViewController = self;
    self.gamBanner.delegate = self;
    
    // Add GMA SDK banner view to the app UI
    [self.bannerView addSubview:self.gamBanner];
    
    // 6. Make a bid request to Prebid Server
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 7. Load GAM Ad
        [self.gamBanner loadRequest:gamRequest];
    }];
}

// MARK: - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    [AdViewUtils findPrebidCreativeSize:bannerView success:^(CGSize size) {
        [self.gamBanner resize:GADAdSizeFromCGSize(size)];
    } failure:^(NSError * _Nonnull error) {
        PBMLogError(@"%@", error.localizedDescription)
    }];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription)
}

@end

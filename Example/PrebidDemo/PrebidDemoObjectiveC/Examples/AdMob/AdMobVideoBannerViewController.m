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

#import "AdMobVideoBannerViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoBannerAdMob = @"prebid-demo-video-outstream";
NSString * const adMobAdUnitVideoBannerRendering = @"ca-app-pub-5922967660082475/9483570409";

@interface AdMobVideoBannerViewController ()

// Prebid
@property (nonatomic) MediationBannerAdUnit * prebidAdMobMediaitonAdUnit;
@property (nonatomic) AdMobMediationBannerUtils * mediationDelegate;

// AdMob
@property (nonatomic) GADBannerView * gadBanner;

@end

@implementation AdMobVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GADRequest
    GADRequest * gadRequest = [GADRequest new];
    
    // 2. Create a GADBannerView
    self.gadBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gadBanner.adUnitID = adMobAdUnitVideoBannerRendering;
    self.gadBanner.delegate = self;
    self.gadBanner.rootViewController = self;
    
    // Add GMA SDK banner view to the app UI
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.gadBanner];
    
    // 3. Create an AdMobMediationBannerUtils
    self.mediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:gadRequest bannerView:self.gadBanner];
    
    // 4. Create a MediationBannerAdUnit
    self.prebidAdMobMediaitonAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:storedImpVideoBannerAdMob size:self.adSize mediationDelegate:self.mediationDelegate];
    
    // 5. Set ad format
    self.prebidAdMobMediaitonAdUnit.adFormat = AdFormat.video;
    
    // 6. Make a bid request to Prebid Server
    @weakify(self);
    [self.prebidAdMobMediaitonAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 7. Load the banner ad
        [self.gadBanner loadRequest:gadRequest];
    }];
}

// MARK: - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
    
    [self.prebidAdMobMediaitonAdUnit adObjectDidFailToLoadAdWithAdObject:self.gadBanner with:error];
}

@end

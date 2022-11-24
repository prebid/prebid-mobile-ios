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

#import "AdMobDisplayBannerViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpDisplayBannerAdMob = @"response-prebid-banner-320-50";
NSString * const storedResponseDisplayBannerAdMob = @"imp-prebid-banner-320-50";
NSString * const adMobAdUnitDisplayBannerRendering = @"ca-app-pub-5922967660082475/9483570409";

@interface AdMobDisplayBannerViewController ()

// Prebid
@property (nonatomic) MediationBannerAdUnit * prebidAdMobMediaitonAdUnit;
@property (nonatomic) AdMobMediationBannerUtils * mediationDelegate;

// AdMob
@property (nonatomic) GADRequest * gadRequest;
@property (nonatomic) GADBannerView * gadBanner;

@end

@implementation AdMobDisplayBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseDisplayBannerAdMob;
    [self createAd];
}

- (void)createAd {
    // Setup GADBannerView
    self.gadBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gadBanner.adUnitID = adMobAdUnitDisplayBannerRendering;
    self.gadBanner.delegate = self;
    self.gadBanner.rootViewController = self;
    
    self.gadRequest = [GADRequest new];
    
    [self.bannerView addSubview:self.gadBanner];
    
    // Setup Prebid banner mediation ad unit
    self.mediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest bannerView:self.gadBanner];
    self.prebidAdMobMediaitonAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:storedImpDisplayBannerAdMob size:self.adSize mediationDelegate:self.mediationDelegate];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
    @weakify(self);
    [self.prebidAdMobMediaitonAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        // Load ad
        [self.gadBanner loadRequest:self.gadRequest];
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

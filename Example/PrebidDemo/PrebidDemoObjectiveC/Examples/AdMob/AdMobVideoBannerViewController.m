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

NSString * const storedImpVideoBannerAdMob = @"imp-prebid-video-outstream";
NSString * const storedResponseVideoBannerAdMob = @"response-prebid-video-outstream";
NSString * const adMobAdUnitVideoBannerRendering = @"ca-app-pub-5922967660082475/9483570409";

@interface AdMobVideoBannerViewController ()

// Prebid
@property (nonatomic) MediationBannerAdUnit * prebidAdMobMediaitonAdUnit;
@property (nonatomic) AdMobMediationBannerUtils * mediationDelegate;

// AdMob
@property (nonatomic) GADRequest * gadRequest;
@property (nonatomic) GADBannerView * gadBanner;

@end

@implementation AdMobVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseVideoBannerAdMob;
    [self createAd];
}

- (void)createAd {
    // Setup GADBannerView
    self.gadBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gadBanner.adUnitID = adMobAdUnitVideoBannerRendering;
    self.gadBanner.delegate = self;
    self.gadBanner.rootViewController = self;
    
    self.gadRequest = [GADRequest new];
    
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.gadBanner];
    
    // Setup Prebid banner mediation ad unit
    self.mediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest bannerView:self.gadBanner];
    self.prebidAdMobMediaitonAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:storedImpVideoBannerAdMob size:self.adSize mediationDelegate:self.mediationDelegate];
    
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

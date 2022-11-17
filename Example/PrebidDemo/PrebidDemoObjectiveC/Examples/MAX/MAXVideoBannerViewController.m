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

#import "MAXVideoBannerViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedResponseVideoBannerMAX = @"response-prebid-video-outstream";
NSString * const storedImpVideoBannerMAX = @"imp-prebid-video-outstream";
NSString * const maxAdUnitBannerVideoRendering = @"6d6c04cfc1c0548e";

@interface MAXVideoBannerViewController ()

// Prebid
@property (nonatomic) MediationBannerAdUnit * maxAdUnit;
@property (nonatomic) MAXMediationBannerUtils * maxMediationDelegate;

// MAX
@property (nonatomic) MAAdView * maxAdBannerView;

@end

@implementation MAXVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseVideoBannerMAX;
    [self createAd];
}

- (void)createAd {
    // Setup integration kind - AppLovin MAX
    self.maxAdBannerView = [[MAAdView alloc] initWithAdUnitIdentifier:maxAdUnitBannerVideoRendering];
    self.maxAdBannerView.frame = CGRectMake(0, 0, self.adSize.width, self.adSize.height);
    self.maxAdBannerView.delegate = self;
    [self.maxAdBannerView setHidden:NO];
    
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.maxAdBannerView];
    
    // Setup Prebid mediation ad unit
    self.maxMediationDelegate = [[MAXMediationBannerUtils alloc] initWithAdView:self.maxAdBannerView];
    self.maxAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:storedImpVideoBannerMAX size:self.adSize mediationDelegate:self.maxMediationDelegate];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
    @weakify(self);
    [self.maxAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        // Load ad
        [self.maxAdBannerView loadAd];
    }];
}

// MARK: - MAAdViewAdDelegate

- (void)didLoadAd:(MAAd *)ad {
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    PBMLogError(@"%@", error.message);
    
    NSError * maxError = [[NSError alloc] initWithDomain:@"MAX" code:error.code userInfo:@{NSLocalizedDescriptionKey: error.message}];
    [self.maxAdUnit adObjectDidFailToLoadAdWithAdObject:self.maxAdBannerView with:maxError];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    PBMLogError(@"%@", error.message);
    
    NSError * maxError = [[NSError alloc] initWithDomain:@"MAX" code:error.code userInfo:@{NSLocalizedDescriptionKey: error.message}];
    [self.maxAdUnit adObjectDidFailToLoadAdWithAdObject:self.maxAdBannerView with:maxError];
}

- (void)didDisplayAd:(MAAd *)ad {
}

- (void)didHideAd:(MAAd *)ad {
}

- (void)didExpandAd:(MAAd *)ad {
}

- (void)didCollapseAd:(MAAd *)ad {
}

- (void)didClickAd:(MAAd *)ad {
}


@end

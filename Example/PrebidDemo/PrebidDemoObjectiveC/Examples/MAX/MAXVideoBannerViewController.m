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

NSString * const storedImpVideoBannerMAX = @"prebid-demo-video-outstream";
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
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a MAAdView
    self.maxAdBannerView = [[MAAdView alloc] initWithAdUnitIdentifier:maxAdUnitBannerVideoRendering];
    
    // 2. Configure the MAAdView
    self.maxAdBannerView.frame = CGRectMake(0, 0, self.adSize.width, self.adSize.height);
    self.maxAdBannerView.delegate = self;
    [self.maxAdBannerView setHidden:NO];
    
    // Add AppLovin SDK banner view to the app UI
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.maxAdBannerView];
    
    // 3. Create a MAXMediationBannerUtils
    self.maxMediationDelegate = [[MAXMediationBannerUtils alloc] initWithAdView:self.maxAdBannerView];
    
    // 4. Create a MediationBannerAdUnit
    self.maxAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:storedImpVideoBannerMAX size:self.adSize mediationDelegate:self.maxMediationDelegate];
    
    // 5. Set ad format
    self.maxAdUnit.adFormat = AdFormat.video;
    
    // 6. Make a bid request to Prebid Server
    @weakify(self);
    [self.maxAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 7. Load the banner ad
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

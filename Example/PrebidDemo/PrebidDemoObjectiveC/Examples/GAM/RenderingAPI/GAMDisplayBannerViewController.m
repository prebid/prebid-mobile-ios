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

#import "GAMDisplayBannerViewController.h"

NSString * const storedResponseDisplayBannerGAMRendering = @"response-prebid-banner-320-50";
NSString * const storedImpDisplayBannerGAMRendering = @"imp-prebid-banner-320-50";
NSString * const gamAdUnitDisplayBannerRendering = @"/21808260008/prebid_oxb_320x50_banner";

@interface GAMDisplayBannerViewController ()

// Prebid
@property (nonatomic) BannerView * prebidBannerView;

// GAM
@property (nonatomic) GAMRequest *gamRequest;
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMDisplayBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseDisplayBannerGAMRendering;
    [self createAd];
}

- (void)createAd {
    // Setup Prebid event handler
    GAMBannerEventHandler * eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:gamAdUnitDisplayBannerRendering validGADAdSizes:@[NSValueFromGADAdSize(GADAdSizeBanner)]];
    self.prebidBannerView = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height) configID:storedImpDisplayBannerGAMRendering adSize:self.adSize eventHandler:eventHandler];
    self.prebidBannerView.delegate = self;
    [self.bannerView addSubview:self.prebidBannerView];
    
    // Load ad
    [self.prebidBannerView loadAd];
}

// MARK: - BannerViewDelegate

- (UIViewController *)bannerViewPresentationController {
    return self;
}

- (void)bannerView:(BannerView *)bannerView didFailToReceiveAdWith:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

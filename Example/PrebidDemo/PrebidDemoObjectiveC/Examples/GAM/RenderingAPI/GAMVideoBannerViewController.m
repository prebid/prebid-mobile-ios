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
#import "GAMVideoBannerViewController.h"

NSString * const storedImpVideoGAMRendering = @"prebid-demo-video-outstream";
NSString * const gamAdUnitVideoRendering = @"/21808260008/prebid_oxb_300x250_banner";

@interface GAMVideoBannerViewController ()

// Prebid
@property (nonatomic) BannerView * prebidBannerView;

// GAM
@property (nonatomic) GAMRequest *gamRequest;
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GAMBannerEventHandler
    GAMBannerEventHandler * eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:gamAdUnitVideoRendering validGADAdSizes:@[NSValueFromGADAdSize(GADAdSizeMediumRectangle)]];
    
    // 2. Create a BannerView
    self.prebidBannerView = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height) configID:storedImpVideoGAMRendering adSize:self.adSize eventHandler:eventHandler];
    
    // 3. Configure the BannerView
    self.prebidBannerView.adFormat = AdFormat.video;
    self.prebidBannerView.videoParameters.placement = PBPlacement.InBanner;
    self.prebidBannerView.delegate = self;
    
    // Add Prebid banner view to the app UI
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.prebidBannerView];
    
    // 4. Load the banner ad
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

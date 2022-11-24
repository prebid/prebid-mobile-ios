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

#import "GAMOriginalAPIVideoBannerViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;
@import GoogleMobileAds;

NSString * const storedResponseOriginalVideoBanner = @"response-prebid-video-outstream-original-api";
NSString * const storedImpVideoBanner = @"imp-prebid-video-outstream";
NSString * const gamAdUnitVideoBannerOriginal = @"/21808260008/prebid-demo-original-api-video-banner";

@interface GAMOriginalAPIVideoBannerViewController ()

// Prebid
@property (nonatomic) VideoAdUnit *adUnit;

// GAM
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMOriginalAPIVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseOriginalVideoBanner;
    [self createAd];
}

- (void)createAd {
    // 1. Create a VideoAdUnit
    self.adUnit = [[VideoAdUnit alloc] initWithConfigId:storedImpVideoBanner size:self.adSize];
    
    // 2. Configure video parameters
    VideoParameters * parameters = [[VideoParameters alloc] init];
    parameters.mimes = @[@"video/mp4"];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    parameters.placement = PBPlacement.InBanner;
    self.adUnit.parameters = parameters;
    
    // 3. Create a GAMBannerView
    GAMRequest * gamRequest = [GAMRequest new];
    self.gamBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gamBanner.adUnitID = gamAdUnitVideoBannerOriginal;
    self.gamBanner.rootViewController = self;
    self.gamBanner.delegate = self;
    
    // Add GMA SDK banner view to the app UI
    self.bannerView.backgroundColor = [UIColor clearColor];
    [self.bannerView addSubview:self.gamBanner];
    
    // 4. Make a bid request to Prebid Server
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        
        // 5. Load GAM Ad
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

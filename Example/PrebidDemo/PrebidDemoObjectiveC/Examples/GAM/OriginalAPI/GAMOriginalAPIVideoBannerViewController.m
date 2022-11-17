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
@property (nonatomic) GAMRequest *gamRequest;
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMOriginalAPIVideoBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseOriginalVideoBanner;
    [self createAd];
}

- (void)createAd {
    // Create a VideoAdUnit associated with a Prebid Server configuration ID and a banner size
    self.adUnit = [[VideoAdUnit alloc] initWithConfigId:storedImpVideoBanner size:self.adSize];
    // Create and setup video parameters
    VideoParameters * parameters = [[VideoParameters alloc] init];
    parameters.mimes = @[@"video/mp4"];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    parameters.placement = PBPlacement.InBanner;
    self.adUnit.parameters = parameters;
    
    // Setup integration kind - GAM
    self.gamRequest = [GAMRequest new];
    self.gamBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gamBanner.adUnitID = gamAdUnitVideoBannerOriginal;
    self.gamBanner.rootViewController = self;
    self.gamBanner.delegate = self;
    [self.bannerView addSubview:self.gamBanner];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit.
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:self.gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        // Load ad
        [self.gamBanner loadRequest:self.gamRequest];
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

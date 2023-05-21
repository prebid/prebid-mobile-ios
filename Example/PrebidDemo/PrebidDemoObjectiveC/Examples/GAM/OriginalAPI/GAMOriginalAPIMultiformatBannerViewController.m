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

#import "GAMOriginalAPIMultiformatBannerViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;
@import GoogleMobileAds;

NSArray<NSString *> * const storedImpsBanner = @[@"prebid-demo-banner-300-250", @"prebid-demo-video-outstream-original-api"];
NSString * const gamAdUnitMultiformatBannerOriginal = @"/21808260008/prebid-demo-original-banner-multiformat";

@interface GAMOriginalAPIMultiformatBannerViewController ()

// Prebid
@property (nonatomic) BannerAdUnit *adUnit;

// GAM
@property (nonatomic) GAMBannerView *gamBanner;

@end

@implementation GAMOriginalAPIMultiformatBannerViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a BannerAdUnit
    NSString * configId = [storedImpsBanner count] ? storedImpsBanner[arc4random_uniform((u_int32_t)[storedImpsBanner count])] : nil;
    self.adUnit = [[BannerAdUnit alloc] initWithConfigId:configId size:self.adSize];
    
    // 2. Set adFormats
    self.adUnit.adFormats = [NSSet setWithObjects:AdFormat.banner, AdFormat.video, nil];
    
    // 3. Configure banner parameters
    BannerParameters * bannerParameters = [[BannerParameters alloc] init];
    bannerParameters.api = @[PBApi.MRAID_2];
    self.adUnit.bannerParameters = bannerParameters;
    
    // 4. Configure video parameters
    VideoParameters * videoParameters = [[VideoParameters alloc] initWithMimes:@[@"video/mp4"]];
    videoParameters.protocols = @[PBProtocols.VAST_2_0];
    videoParameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    videoParameters.placement = PBPlacement.InBanner;
    self.adUnit.videoParameters = videoParameters;
    
    // 5. Create a GAMBannerView
    GAMRequest * gamRequest = [GAMRequest new];
    self.gamBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.adSize)];
    self.gamBanner.adUnitID = gamAdUnitMultiformatBannerOriginal;
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
    self.bannerView.backgroundColor = UIColor.clearColor;
    
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

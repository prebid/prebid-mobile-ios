/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

#import "GAMOriginalAPIMultiformatNativeStylesViewController.h"

NSArray<NSString *> * const multiformatNativeStylesStoredPrebidImpressions = @[@"prebid-demo-banner-300-250", @"prebid-demo-video-outstream-original-api", @"prebid-demo-banner-native-styles"];
NSString * const gamMultiformatNativeStylesAdUnitId = @"/21808260008/prebid-demo-multiformat-native-styles";

@interface GAMOriginalAPIMultiformatNativeStylesViewController ()

// Prebid
@property (nonatomic) PrebidAdUnit * adUnit;
@property (nonatomic) NSString * configId;

// GAM
@property (nonatomic) GAMBannerView * gamBannerView;

@end

@implementation GAMOriginalAPIMultiformatNativeStylesViewController

- (NSArray<NativeAsset *> *)nativeAssets {
    NativeAssetImage *image = [[NativeAssetImage alloc] initWithMinimumWidth:200 minimumHeight:200 required:true];
    image.type = ImageAsset.Main;
    
    NativeAssetImage *icon = [[NativeAssetImage alloc] initWithMinimumWidth:20 minimumHeight:20 required:true];
    icon.type = ImageAsset.Icon;
    
    NativeAssetTitle *title = [[NativeAssetTitle alloc] initWithLength:90 required:true];
    NativeAssetData *body = [[NativeAssetData alloc] initWithType:DataAssetDescription required:true];
    NativeAssetData *cta = [[NativeAssetData alloc] initWithType:DataAssetCtatext required:true];
    NativeAssetData *sponsored = [[NativeAssetData alloc] initWithType:DataAssetSponsored required:true];
    
    return @[title, icon, image, sponsored, body, cta];
}

- (NSArray<NativeEventTracker *> *)eventTrackers {
    NativeEventTracker * eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.Impression
                                                                          methods:@[EventTracking.Image, EventTracking.js]];
    
    return @[eventTracker];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createAd];
}

- (void)createAd {
    // 1. Setup a PrebidAdUnit
    self.configId = [multiformatNativeStylesStoredPrebidImpressions count] ? multiformatNativeStylesStoredPrebidImpressions[arc4random_uniform((u_int32_t)[multiformatNativeStylesStoredPrebidImpressions count])] : nil;
    self.adUnit = [[PrebidAdUnit alloc] initWithConfigId:self.configId];
    [self.adUnit setAutoRefreshMillisWithTime:30000];
    
    // 2. Setup the parameters
    BannerParameters * bannerParameters = [BannerParameters new];
    bannerParameters.api = @[PBApi.MRAID_2];
    [bannerParameters setAdSizes:@[[NSValue valueWithCGSize:self.adSize]]];
    
    VideoParameters * videoParameters = [[VideoParameters alloc] initWithMimes:@[@"video/mp4"]];
    videoParameters.protocols = @[PBProtocols.VAST_2_0];
    videoParameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    videoParameters.placement = PBPlacement.InBanner;
    [videoParameters setSize:[NSValue valueWithCGSize:self.adSize]];
    
    NativeParameters * nativeParameters = [NativeParameters new];
    nativeParameters.assets = [self nativeAssets];
    nativeParameters.context = ContextType.Social;
    nativeParameters.placementType = PlacementType.FeedContent;
    nativeParameters.contextSubType = ContextSubType.Social;
    nativeParameters.eventtrackers = [self eventTrackers];
    
    // 3. Configure the PrebidRequest
    PrebidRequest * prebidRequest = [[PrebidRequest alloc] initWithBannerParameters:bannerParameters videoParameters:videoParameters nativeParameters:nativeParameters isInterstitial:NO isRewarded:NO];
    
    // 4. Create a GAMBannerView
    self.gamBannerView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFluid];
    self.gamBannerView.validAdSizes = @[NSValueFromGADAdSize(GADAdSizeFluid), NSValueFromGADAdSize(GADAdSizeBanner), NSValueFromGADAdSize(GADAdSizeMediumRectangle)];
    self.gamBannerView.adUnitID = gamMultiformatNativeStylesAdUnitId;
    self.gamBannerView.rootViewController = self;
    self.gamBannerView.delegate = self;
    
    // Add GMA SDK banner view to the app UI
    [self.bannerView addSubview:self.gamBannerView];
    
    // 4. Make a bid request
    GAMRequest * gamRequest = [GAMRequest new];
    [self.adUnit fetchDemandWithAdObject:gamRequest request:prebidRequest completion:^(PBMBidInfo * _Nonnull bidInfo) {
        
        // 5. Load the native ad
        [self.gamBannerView loadRequest:gamRequest];
    }];
}

// MARK: - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    self.bannerView.backgroundColor = UIColor.clearColor;
    
    [AdViewUtils findPrebidCreativeSize:bannerView success:^(CGSize size) {
        [self.gamBannerView resize:GADAdSizeFromCGSize(size)];
    } failure:^(NSError * _Nonnull error) {
        PBMLogError(@"%@", error.localizedDescription)
    }];
    
    NSLayoutConstraint * centerConstraint = [NSLayoutConstraint constraintWithItem:self.gamBannerView attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual toItem:self.bannerView
                                                                         attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.view addConstraint:centerConstraint];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription)
}

@end

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

#import "GAMOriginalAPIMultiformatInAppNativeViewController.h"

NSArray<NSString *> * const multiformatStoredPrebidImpressions = @[@"prebid-demo-banner-300-250", @"prebid-demo-video-outstream-original-api", @"prebid-demo-banner-native-styles"];
NSString * const gamMultiformatAdUnitId = @"/21808260008/prebid-demo-multiformat";

@interface GAMOriginalAPIMultiformatInAppNativeViewController ()

// Prebid
@property (nonatomic) PrebidAdUnit * adUnit;
@property (nonatomic) NativeAd * nativeAd;

@property (nonatomic) NSString * configId;

// GAM
@property (nonatomic) GADAdLoader * adLoader;

@end

@implementation GAMOriginalAPIMultiformatInAppNativeViewController

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
    self.configIdLabel.text = [NSString stringWithFormat:@"ConfigId: %@", self.configId];;
}

- (void)createAd {
    // 1. Setup a PrebidAdUnit
    self.configId = [multiformatStoredPrebidImpressions count] ? multiformatStoredPrebidImpressions[arc4random_uniform((u_int32_t)[multiformatStoredPrebidImpressions count])] : nil;
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
    
    // 4. Make a bid request
    GAMRequest * gamRequest = [GAMRequest new];
    [self.adUnit fetchDemandWithAdObject:gamRequest request:prebidRequest completion:^(PBMBidInfo * _Nonnull bidInfo) {
        
        // 5. Configure and make a GAM ad request
        self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:gamMultiformatAdUnitId
                                           rootViewController:self
                                                      adTypes:@[GADAdLoaderAdTypeCustomNative, GADAdLoaderAdTypeGAMBanner]
                                                      options:@[]];
        self.adLoader.delegate = self;
        [self.adLoader loadRequest:gamRequest];
    }];
}

// MARK: - GAMBannerAdLoaderDelegate

- (NSArray<NSValue *> *)validBannerSizesForAdLoader:(GADAdLoader *)adLoader {
    return @[NSValueFromGADAdSize(GADAdSizeFromCGSize(self.adSize))];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveGAMBannerView:(GAMBannerView *)bannerView {
    [self.nativeView setHidden:YES];
    [self.bannerView setHidden:NO];
    self.bannerView.backgroundColor = UIColor.clearColor;
    [self.bannerView addSubview:bannerView];
    
    [AdViewUtils findPrebidCreativeSize:bannerView success:^(CGSize size) {
        [bannerView resize:GADAdSizeFromCGSize(size)];
        
        [self.bannerView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.firstAttribute == NSLayoutAttributeWidth;
        }]].firstObject.constant = size.width;
        
        [self.bannerView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.firstAttribute == NSLayoutAttributeHeight;
        }]].firstObject.constant = size.height;
    } failure:^(NSError * _Nonnull error) {
        PBMLogError(@"%@", error.localizedDescription)
    }];
}

- (NSArray<NSString *> *)customNativeAdFormatIDsForAdLoader:(GADAdLoader *)adLoader {
    return @[@"12304464"];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
    Utils.shared.delegate = self;
    [Utils.shared findNativeWithAdObject:customNativeAd];
}

// MARK: - NativeAdDelegate

- (void)nativeAdLoadedWithAd:(NativeAd *)ad {
    [self.nativeView setHidden:NO];
    [self.bannerView setHidden:YES];
    
    self.nativeAd = ad;
    self.titleLable.text = ad.title;
    self.bodyLabel.text = ad.text;
    [self.callToActionButton setTitle:ad.callToAction forState:UIControlStateNormal];
    self.sponsoredLabel.text = ad.sponsoredBy;
    
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:self.nativeAd.iconUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.image = [[UIImage alloc] initWithData:data];
        });
    }] resume];
    
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:self.nativeAd.imageUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainImageView.image = [[UIImage alloc] initWithData:data];
        });
    }] resume];
    
    [self.nativeAd registerViewWithView:self.view clickableViews:@[self.callToActionButton]];
}

- (void)nativeAdNotFound {
    PBMLogError(@"Native ad not found.");
}

- (void)nativeAdNotValid {
    PBMLogError(@"Native ad not valid.");
}

@end

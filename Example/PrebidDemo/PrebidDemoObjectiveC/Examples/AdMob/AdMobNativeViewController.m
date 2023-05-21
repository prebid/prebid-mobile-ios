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

#import "AdMobNativeViewController.h"
#import "PrebidDemoMacros.h"

NSString * const nativeStoredImpressionAdMob = @"prebid-demo-banner-native-styles";
NSString * const admobRenderingNativeAdUnitId = @"ca-app-pub-5922967660082475/8634069303";

@interface AdMobNativeViewController ()

// Prebid
@property (nonatomic) NativeAd * nativeAd;
@property (nonatomic) AdMobMediationNativeUtils * mediationDelegate;
@property (nonatomic) MediationNativeAdUnit * admobMediationNativeAdUnit;

// AdMob
@property (nonatomic) GADAdLoader * adLoader;

@end

@implementation AdMobNativeViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GADRequest
    GADRequest * gadRequest = [GADRequest new];
    
    // 2. Create an AdMobMediationNativeUtils
    self.mediationDelegate = [[AdMobMediationNativeUtils alloc] initWithGadRequest:gadRequest];
    
    // 3. Create a MediationNativeAdUnit
    self.admobMediationNativeAdUnit = [[MediationNativeAdUnit alloc] initWithConfigId:nativeStoredImpressionAdMob mediationDelegate:self.mediationDelegate];
    
    // 4. Configure MediationNativeAdUnit
    NativeAssetImage *image = [[NativeAssetImage alloc] initWithMinimumWidth:200 minimumHeight:200 required:true];
    image.type = ImageAsset.Main;
    
    NativeAssetImage *icon = [[NativeAssetImage alloc] initWithMinimumWidth:20 minimumHeight:20 required:true];
    icon.type = ImageAsset.Icon;
    
    NativeAssetTitle *title = [[NativeAssetTitle alloc] initWithLength:90 required:true];
    NativeAssetData *body = [[NativeAssetData alloc] initWithType:DataAssetDescription required:true];
    NativeAssetData *cta = [[NativeAssetData alloc] initWithType:DataAssetCtatext required:true];
    NativeAssetData *sponsored = [[NativeAssetData alloc] initWithType:DataAssetSponsored required:true];
    
    NativeEventTracker * eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.Impression
                                                                          methods:@[EventTracking.Image, EventTracking.js]];
    
    [self.admobMediationNativeAdUnit addNativeAssets:@[title, icon, image, sponsored, body, cta]];
    [self.admobMediationNativeAdUnit addEventTracker:@[eventTracker]];
    
    [self.admobMediationNativeAdUnit setContextType:ContextType.Social];
    [self.admobMediationNativeAdUnit setPlacementType:PlacementType.FeedContent];
    [self.admobMediationNativeAdUnit setContextSubType:ContextSubType.Social];
    
    // 5. Make a bid request to Prebid Server
    @weakify(self);
    [self.admobMediationNativeAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 6. Load the native ad
        self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:admobRenderingNativeAdUnitId
                                           rootViewController:self
                                                      adTypes:@[GADAdLoaderAdTypeNative]
                                                      options:@[]];
        self.adLoader.delegate = self;
        [self.adLoader loadRequest:gadRequest];
    }];
}

// MARK: - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    self.titleLable.text = nativeAd.headline;
    self.bodyLabel.text = nativeAd.body;
    [self.callToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    self.sponsoredLabel.text = nativeAd.advertiser;
    
    self.iconView.image = nativeAd.icon.image;
    self.mainImageView.image = nativeAd.images.firstObject.image;
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

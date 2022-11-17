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

#import "GAMOriginalAPINativeBannerViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const nativeBannerStoredResponse = @"response-prebid-banner-native-styles";
NSString * const nativeStoredBannerImpression = @"imp-prebid-banner-native-styles";
NSString * const gamAdUnit = @"/21808260008/unified_native_ad_unit";

@interface GAMOriginalAPINativeBannerViewController ()

// Prebid
@property (nonatomic) NativeRequest * nativeUnit;

// GAM
@property (nonatomic) GAMBannerView * gamBannerView;
@property (nonatomic) GAMRequest * gamRequest;

@end

@implementation GAMOriginalAPINativeBannerViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = nativeBannerStoredResponse;
    [self createAd];
}

- (void)createAd {
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
    
    // Setup Prebid AdUnit
    self.nativeUnit = [[NativeRequest alloc] initWithConfigId:nativeStoredBannerImpression
                                                       assets:@[title, icon, image, sponsored, body, cta]
                                                eventTrackers:@[eventTracker]];
    self.nativeUnit.context = ContextType.Social;
    self.nativeUnit.placementType = PlacementType.FeedContent;
    self.nativeUnit.contextSubType = ContextSubType.Social;
    
    // Setup integration kind - GAM
    self.gamBannerView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFluid];
    self.gamRequest = [GAMRequest new];
    self.gamBannerView.adUnitID = gamAdUnit;
    self.gamBannerView.rootViewController = self;
    self.gamBannerView.delegate = self;
    [self.bannerView addSubview:self.gamBannerView];
    
    // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
    @weakify(self);
    [self.nativeUnit fetchDemandWithAdObject:self.gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        // Load ad
        [self.gamBannerView loadRequest:self.gamRequest];
    }];
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    [AdViewUtils findPrebidCreativeSize:bannerView success:^(CGSize size) {
        [self.gamBannerView resize:GADAdSizeFromCGSize(size)];
    } failure:^(NSError * _Nonnull error) {
        PBMLogError(@"%@", error.localizedDescription)
    }];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription)
}

@end

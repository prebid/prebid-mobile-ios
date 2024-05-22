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

#import "MAXNativeViewController.h"
#import "PrebidDemoMacros.h"

NSString * const nativeStoredImpressionMAX = @"prebid-demo-banner-native-styles";
NSString * const maxRenderingNativeAdUnitId = @"240da3ba91611d72";

@interface MAXNativeViewController ()

// Prebid
@property (nonatomic) MediationNativeAdUnit * maxMediationNativeAdUnit;
@property (nonatomic) MAXMediationNativeUtils * mediationDelegate;

// MAX
@property (nonatomic) MANativeAdLoader * maxNativeAdLoader;
@property (nonatomic, weak) MAAd * maxLoadedNativeAd;

@end

@implementation MAXNativeViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)dealloc {
    if (self.maxLoadedNativeAd != nil) {
        [self.maxNativeAdLoader destroyAd:self.maxLoadedNativeAd];
    }
}

- (void)createAd {
    // 1. Create a MANativeAdLoader
    self.maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:maxRenderingNativeAdUnitId];
    self.maxNativeAdLoader.nativeAdDelegate = self;
    
    // 2. Create the MAXMediationNativeUtils
    self.mediationDelegate = [[MAXMediationNativeUtils alloc] initWithNativeAdLoader:self.maxNativeAdLoader];
    
    // 3. Create the MediationNativeAdUnit
    self.maxMediationNativeAdUnit = [[MediationNativeAdUnit alloc] initWithConfigId:nativeStoredImpressionMAX mediationDelegate:self.mediationDelegate];
    
    // 4. Configure the MediationNativeAdUnit
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
    [self.maxMediationNativeAdUnit addNativeAssets:@[title, icon, image, sponsored, body, cta]];
    [self.maxMediationNativeAdUnit addEventTracker:@[eventTracker]];
    
    [self.maxMediationNativeAdUnit setContextType:ContextType.Social];
    [self.maxMediationNativeAdUnit setPlacementType:PlacementType.FeedContent];
    [self.maxMediationNativeAdUnit setContextSubType:ContextSubType.Social];
    
    // 5. Create a MAXNativeAdView
    UINib * nativeAdViewNib = [UINib nibWithNibName:@"MAXNativeAdView" bundle:NSBundle.mainBundle];
    MANativeAdView * maNativeAdView = [nativeAdViewNib instantiateWithOwner:nil options:nil].firstObject;
    
    // 6. Create a MANativeAdViewBinder
    MANativeAdViewBinder * adViewBinder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder * _Nonnull builder) {
        builder.iconImageViewTag = 1;
        builder.titleLabelTag = 2;
        builder.bodyLabelTag = 3;
        builder.advertiserLabelTag = 4;
        builder.callToActionButtonTag = 5;
        builder.mediaContentViewTag = 123;
    }];
    
    // 7. Bind views
    [maNativeAdView bindViewsWithAdViewBinder:adViewBinder];
    
    // 7. Make a bid request to Prebid Server
    @weakify(self);
    [self.maxMediationNativeAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @strongify(self);
        if (!self) { return; }
        
        // 8. Load the native ad
        [self.maxNativeAdLoader loadAdIntoAdView:maNativeAdView];
    }];
}

// MARK: - MANativeAdDelegate

- (void)didLoadNativeAd:(MANativeAdView *)nativeAdView forAd:(MAAd *)ad {
    if (self.maxLoadedNativeAd != nil) {
        [self.maxNativeAdLoader destroyAd:self.maxLoadedNativeAd];
    }
    
    self.maxLoadedNativeAd = ad;
    
    self.bannerView.backgroundColor = [UIColor clearColor];
    
    nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bannerView addSubview:nativeAdView];
    
    [[self.bannerView.heightAnchor constraintEqualToAnchor:nativeAdView.heightAnchor] setActive:YES];
    [[self.bannerView.topAnchor constraintEqualToAnchor:nativeAdView.topAnchor] setActive:YES];
    [[self.bannerView.leftAnchor constraintEqualToAnchor:nativeAdView.leftAnchor] setActive:YES];
    [[self.bannerView.rightAnchor constraintEqualToAnchor:nativeAdView.rightAnchor] setActive:YES];
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    PBMLogError(@"%@", error.message);
}

- (void)didClickNativeAd:(MAAd *)ad {
}

@end

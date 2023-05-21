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

#import "GAMNativeViewController.h"
#import "PrebidDemoMacros.h"

NSString * const nativeStoredImpressionRendering = @"prebid-demo-banner-native-styles";
NSString * const gamRenderingNativeAdUnitId = @"/21808260008/apollo_custom_template_native_ad_unit";

@interface GAMNativeViewController ()

// Prebid
@property (nonatomic) NativeRequest * nativeUnit;
@property (nonatomic) NativeAd * nativeAd;

// GAM
@property (nonatomic) GADAdLoader * adLoader;

@end

@implementation GAMNativeViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a NativeRequest
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
    
    self.nativeUnit = [[NativeRequest alloc] initWithConfigId:nativeStoredImpressionRendering
                                                       assets:@[title, icon, image, sponsored, body, cta]
                                                eventTrackers:@[eventTracker]];
    
    // 2. Configure the NativeRequest
    self.nativeUnit.context = ContextType.Social;
    self.nativeUnit.placementType = PlacementType.FeedContent;
    self.nativeUnit.contextSubType = ContextSubType.Social;
    
    // 3. Make a bid request to Prebid Server
    @weakify(self);
    [self.nativeUnit fetchDemandWithCompletion:^(enum ResultCode resultCode, NSDictionary<NSString *,NSString *> * _Nullable kvResultDict) {
        @strongify(self);
        if (!self) { return; }
        
        // 4. Prepare GAM request
        GAMRequest * gamRequest = [GAMRequest new];
        [GAMUtils.shared prepareRequest:gamRequest bidTargeting:kvResultDict ?: @{}];
        
        // 5. Load the native ad
        self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:gamRenderingNativeAdUnitId
                                           rootViewController:self
                                                      adTypes:@[GADAdLoaderAdTypeCustomNative] options:@[]];
        self.adLoader.delegate = self;
        [self.adLoader loadRequest:gamRequest];
    }];
}

// MARK: - GADCustomNativeAdLoaderDelegate

- (NSArray<NSString *> *)customNativeAdFormatIDsForAdLoader:(GADAdLoader *)adLoader {
    return @[@"11934135"];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
    [GAMUtils.shared findCustomNativeAdObjcFor:customNativeAd completion:^(NativeAd * _Nullable nativeAd, NSError * _Nullable error) {
        if (error != nil && [error.domain isEqual: GAMUtils.errorDomain] && error.code == GAMEventHandlerErrorNonPrebidAd) {
            self.titleLable.text = [customNativeAd stringForKey:@"title"];
            self.bodyLabel.text = [customNativeAd stringForKey:@"text"];
            self.sponsoredLabel.text = [customNativeAd stringForKey:@"sponsoredBy"];
            [self.callToActionButton setTitle:[customNativeAd stringForKey:@"cta"] forState:UIControlStateNormal];
            
            NSString * imgURL = [customNativeAd stringForKey:@"imgUrl"];
            NSString * iconURL = [customNativeAd stringForKey:@"iconUrl"];
            
            if (imgURL != nil) {
                [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:imgURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.mainImageView.image = [[UIImage alloc] initWithData:data];
                    });
                }] resume];
            }
            
            if (iconURL != nil) {
                [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:self.nativeAd.iconUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.iconView.image = [[UIImage alloc] initWithData:data];
                    });
                }] resume];
            }
        } else if (nativeAd != nil) {
            self.nativeAd = nativeAd;
            
            self.titleLable.text = nativeAd.title;
            self.bodyLabel.text = nativeAd.text;
            [self.callToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];
            self.sponsoredLabel.text = nativeAd.sponsoredBy;
            
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
    }];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

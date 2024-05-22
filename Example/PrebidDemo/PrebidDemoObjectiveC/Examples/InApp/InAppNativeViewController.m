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

#import "InAppNativeViewController.h"
#import "PrebidDemoMacros.h"

NSString * const nativeStoredImpressionInApp = @"prebid-demo-banner-native-styles";

@interface InAppNativeViewController ()

// Prebid
@property (nonatomic) NativeAd * nativeAd;
@property (nonatomic) NativeRequest * nativeUnit;

@end

@implementation InAppNativeViewController

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
    
    self.nativeUnit = [[NativeRequest alloc] initWithConfigId:nativeStoredImpressionInApp
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
        
        // 4. Find cached native ad
        NSString * cacheId = [kvResultDict valueForKey:@"hb_cache_id_local"];
        
        // 5. Create a NativeAd
        NativeAd * nativeAd = [NativeAd createWithCacheId:cacheId];
        
        if (nativeAd == nil) {
            return;
        }
        
        self.nativeAd = nativeAd;
        
        // 6. Render the native ad
        self.titleLable.text = self.nativeAd.title;
        self.bodyLabel.text = self.nativeAd.text;
        [self.callToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
        self.sponsoredLabel.text = self.nativeAd.sponsoredBy;
        
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
    }];
}

@end

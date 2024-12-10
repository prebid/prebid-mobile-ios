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

#import "InAppDisplayBannerPluginRendererViewController.h"
#import "PrebidDemoMacros.h"
#import "SampleRenderer.h"

NSString * const storedImpDisplayBannerPluginRendererInApp = @"prebid-demo-display-banner-320-50-custom-ad-view-renderer";

@interface InAppDisplayBannerPluginRendererViewController ()

// Prebid
@property (nonatomic) BannerView * prebidBannerView;
@property (nonatomic, strong) SampleRenderer * samplePluginRenderer;

@end

@implementation InAppDisplayBannerPluginRendererViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)dealloc {
    // Unregister plugin when you no longer needed
    [Prebid unregisterPluginRenderer:self.samplePluginRenderer];
}

- (void)createAd {
    // 1. Create a plugin renderer
    self.samplePluginRenderer = [SampleRenderer new];
    
    // 2. Register the plugin renderer
    [Prebid registerPluginRenderer:self.samplePluginRenderer];
    
    // 3. Create a BannerView
    self.prebidBannerView = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height)
                                                     configID:storedImpDisplayBannerPluginRendererInApp
                                                       adSize:self.adSize];
    
    // 4. Configure the BannerView
    self.prebidBannerView.delegate = self;
    self.prebidBannerView.adFormat = AdFormat.banner;
    self.prebidBannerView.videoParameters.placement = PBPlacement.InBanner;
    
    // Add Prebid banner view to the app UI
    [self.bannerView addSubview:self.prebidBannerView];
    
    // 5. Load the banner ad
    [self.prebidBannerView loadAd];
}

// MARK: - BannerViewDelegate

- (UIViewController *)bannerViewPresentationController {
    return self;
}

- (void)bannerView:(BannerView *)bannerView didFailToReceiveAdWith:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

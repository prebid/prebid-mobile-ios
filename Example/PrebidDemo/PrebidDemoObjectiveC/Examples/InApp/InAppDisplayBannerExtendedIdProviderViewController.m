/*   Copyright 2018-2026 Prebid.org, Inc.

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

#import "InAppDisplayBannerExtendedIdProviderViewController.h"
#import "PrebidDemoMacros.h"
#import "SampleExtendedIdProvider.h"

NSString * const storedImpDisplayBannerExtendedIdProviderInApp = @"prebid-demo-banner-320-50";

@interface InAppDisplayBannerExtendedIdProviderViewController ()

// Prebid
@property (nonatomic) BannerView * prebidBannerView;
@property (nonatomic, strong) SampleExtendedIdProvider * sampleIdProvider;

@end

@implementation InAppDisplayBannerExtendedIdProviderViewController

- (void)loadView {
    [super loadView];

    [self createAd];
}

- (void)dealloc {
    // Unregister the provider when its IDs should no longer be sent
    [Prebid unregisterPlugin:self.sampleIdProvider as:PluginCapability.extendedIds];
}

- (void)createAd {
    // 1. Create an extended ID provider
    self.sampleIdProvider = [SampleExtendedIdProvider new];

    // 2. Register the provider. Its IDs are added to every bid request while it is registered, so an app
    // usually registers its providers once, after initializing the SDK. This example registers it only
    // while the screen is shown.
    [Prebid registerPlugin:self.sampleIdProvider as:PluginCapability.extendedIds];

    // The EIDs the SDK adds to bid requests: the IDs set through Targeting, then SharedID if it is
    // enabled, then the IDs of each registered provider
    NSLog(@"EID sources added to bid requests: %@", [[Targeting.shared getExtendedIds] valueForKey:@"source"]);

    // 3. Create a BannerView
    self.prebidBannerView = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height)
                                                     configID:storedImpDisplayBannerExtendedIdProviderInApp
                                                       adSize:self.adSize];

    // 4. Configure the BannerView
    self.prebidBannerView.delegate = self;
    self.prebidBannerView.adFormats = [NSSet setWithObject:AdFormat.banner];
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

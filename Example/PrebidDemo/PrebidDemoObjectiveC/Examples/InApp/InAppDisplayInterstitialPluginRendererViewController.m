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

#import "InAppDisplayInterstitialPluginRendererViewController.h"
#import "PrebidDemoMacros.h"
#import "SampleRenderer.h"

NSString * const storedImpDisplayInterstitialPluginRendererInApp = @"prebid-demo-display-interstitial-320-480-custom-interstitial-renderer";

@interface InAppDisplayInterstitialPluginRendererViewController ()

// Prebid
@property (nonatomic) InterstitialRenderingAdUnit * renderingInterstitial;
@property (nonatomic, strong) SampleRenderer * samplePluginRenderer;

@end

@implementation InAppDisplayInterstitialPluginRendererViewController

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
    
    // 3. Create a InterstitialRenderingAdUnit
    self.renderingInterstitial = [[InterstitialRenderingAdUnit alloc] initWithConfigID:storedImpDisplayInterstitialPluginRendererInApp];
    
    // 4. Configure the InterstitialRenderingAdUnit
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:AdFormat.banner, nil];
    self.renderingInterstitial.delegate = self;
    
    // 5. Load the interstitial ad
    [self.renderingInterstitial loadAd];
}

// MARK: - InterstitialAdUnitDelegate

- (void)interstitialDidReceiveAd:(InterstitialRenderingAdUnit *)interstitial {
    [self.renderingInterstitial showFrom:self];
}

- (void)interstitial:(InterstitialRenderingAdUnit *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

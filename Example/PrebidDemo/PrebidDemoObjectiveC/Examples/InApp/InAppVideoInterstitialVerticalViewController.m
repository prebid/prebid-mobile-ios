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

#import "InAppVideoInterstitialVerticalViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoInterstitialVerticalInApp = @"prebid-demo-video-interstitial-vertical";

@interface InAppVideoInterstitialVerticalViewController ()

// Prebid
@property (nonatomic) InterstitialRenderingAdUnit * renderingInterstitial;

@end

@implementation InAppVideoInterstitialVerticalViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create an InterstitialRenderingAdUnit
    self.renderingInterstitial = [[InterstitialRenderingAdUnit alloc] initWithConfigID:storedImpVideoInterstitialVerticalInApp];
    
    // 2. Configure the InterstitialRenderingAdUnit
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:AdFormat.video, nil];
    self.renderingInterstitial.delegate = self;
    
    // 3. Load the interstitial ad
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

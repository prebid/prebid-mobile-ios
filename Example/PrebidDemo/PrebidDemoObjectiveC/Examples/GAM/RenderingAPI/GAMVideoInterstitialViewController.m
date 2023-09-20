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

#import "GAMVideoInterstitialViewController.h"

NSString * const storedImpGAMVideoInterstitial = @"prebid-demo-video-interstitial-320-480-original-api";
NSString * const gamAdUnitVideoInterstitialRendering = @"/21808260008/prebid_oxb_interstitial_video";

@interface GAMVideoInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialRenderingAdUnit * renderingInterstitial;

@end

@implementation GAMVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a GAMInterstitialEventHandler
    GAMInterstitialEventHandler * eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:gamAdUnitVideoInterstitialRendering];
    
    // 2. Create a InterstitialRenderingAdUnit
    self.renderingInterstitial = [[InterstitialRenderingAdUnit alloc] initWithConfigID:storedImpGAMVideoInterstitial minSizePercentage:CGSizeMake(30, 30) eventHandler:eventHandler];
    
    // 3. Configure the InterstitialRenderingAdUnit
    self.renderingInterstitial.delegate = self;
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:AdFormat.video, nil];
    
    // 4. Load the interstitial ad
    [self.renderingInterstitial loadAd];
}

// MARK: - InterstitialAdUnitDelegate

- (void)interstitialDidReceiveAd:(InterstitialRenderingAdUnit *)interstitial {
    [interstitial showFrom:self];
}

- (void)interstitial:(InterstitialRenderingAdUnit *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

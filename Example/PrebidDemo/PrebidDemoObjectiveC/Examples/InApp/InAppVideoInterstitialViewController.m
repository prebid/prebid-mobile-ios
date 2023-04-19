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

#import "InAppVideoInterstitialViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoInterstitialInApp = @"imp-prebid-video-interstitial-320-480";

@interface InAppVideoInterstitialViewController ()

// Prebid
@property (nonatomic) PBMInterstitialRenderingAdUnit * renderingInterstitial;

@end

@implementation InAppVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    [self createAd];
}

- (void)createAd {
    // 1. Create a InterstitialRenderingAdUnit
    self.renderingInterstitial = [[PBMInterstitialRenderingAdUnit alloc] initWithConfigID:storedImpVideoInterstitialInApp];
    
    // 2. Configure the InterstitialRenderingAdUnit
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:PBMAdFormat.video, nil];
    self.renderingInterstitial.delegate = self;
    
    // 3. Load the interstitial ad
    [self.renderingInterstitial loadAd];
}

// MARK: - InterstitialAdUnitDelegate

- (void)interstitialDidReceiveAd:(PBMInterstitialRenderingAdUnit *)interstitial {
    [self.renderingInterstitial showFrom:self];
}

- (void)interstitial:(PBMInterstitialRenderingAdUnit *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end

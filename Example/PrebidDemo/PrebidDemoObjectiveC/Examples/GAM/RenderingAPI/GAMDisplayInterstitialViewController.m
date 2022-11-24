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

#import "GAMDisplayInterstitialViewController.h"

NSString * const storedImpGAMDisplayInterstitial = @"imp-prebid-display-interstitial-320-480";
NSString * const storedResponseGAMDisplayInterstitial = @"response-prebid-display-interstitial-320-480";
NSString * const gamAdUnitDisplayInterstitialRendering = @"/21808260008/prebid_oxb_html_interstitial";

@interface GAMDisplayInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialRenderingAdUnit * renderingInterstitial;

@end

@implementation GAMDisplayInterstitialViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseGAMDisplayInterstitial;
    [self createAd];
}

- (void)createAd {
    // 1. Create a GAMInterstitialEventHandler
    GAMInterstitialEventHandler * eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:gamAdUnitDisplayInterstitialRendering];
    
    // 2. Create a InterstitialRenderingAdUnit
    self.renderingInterstitial = [[InterstitialRenderingAdUnit alloc] initWithConfigID:storedImpGAMDisplayInterstitial minSizePercentage:CGSizeMake(30, 30) eventHandler:eventHandler];
    self.renderingInterstitial.delegate = self;
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:AdFormat.display, nil];
    
    // 3. Load the interstitial ad
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

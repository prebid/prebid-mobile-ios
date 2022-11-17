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

#import "InAppDisplayInterstitialViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpDisplayInterstitialInApp = @"imp-prebid-display-interstitial-320-480";
NSString * const storedResponseDisplayInterstitialInApp = @"response-prebid-display-interstitial-320-480";

@interface InAppDisplayInterstitialViewController ()

// Prebid
@property (nonatomic) InterstitialRenderingAdUnit * renderingInterstitial;

@end

@implementation InAppDisplayInterstitialViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseDisplayInterstitialInApp;
    [self createAd];
}

- (void)createAd {
    // Setup Prebid ad unit
    self.renderingInterstitial = [[InterstitialRenderingAdUnit alloc] initWithConfigID:storedImpDisplayInterstitialInApp];
    self.renderingInterstitial.adFormats = [[NSSet alloc] initWithObjects:AdFormat.display, nil];
    self.renderingInterstitial.delegate = self;
    // Load ad
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

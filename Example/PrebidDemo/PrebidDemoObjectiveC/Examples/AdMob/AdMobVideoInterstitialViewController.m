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

#import "AdMobVideoInterstitialViewController.h"
#import "PrebidDemoMacros.h"

NSString * const storedImpVideoInterstitialAdMob = @"imp-prebid-video-interstitial-320-480";
NSString * const storedResponseRenderingVideoInterstitialAdMob = @"response-prebid-video-interstitial-320-480";
NSString * const adMobAdUnitVideoInterstitialRendering = @"ca-app-pub-5922967660082475/3383099861";

@interface AdMobVideoInterstitialViewController ()

// Prebid
@property (nonatomic) MediationInterstitialAdUnit * admobAdUnit;
@property (nonatomic) AdMobMediationInterstitialUtils * mediationDelegate;

// AdMob
@property (nonatomic) GADRequest * gadRequest;
@property (nonatomic) GADInterstitialAd * interstitial;

@end

@implementation AdMobVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseRenderingVideoInterstitialAdMob;
    [self createAd];
}

- (void)createAd {
    // Setup integration kind - AdMob
    self.gadRequest = [GADRequest new];
    
    // Setup Prebid interstitial mediation ad unit
    self.mediationDelegate = [[AdMobMediationInterstitialUtils alloc] initWithGadRequest:self.gadRequest];
    self.admobAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:storedImpVideoInterstitialAdMob mediationDelegate:self.mediationDelegate];
    
    [self.admobAdUnit fetchDemandWithCompletion:^(enum ResultCode resultCode) {
        @weakify(self);
        [GADInterstitialAd loadWithAdUnitID:adMobAdUnitVideoInterstitialRendering request:self.gadRequest completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            @strongify(self);
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
                return;
            }
            
            if (interstitialAd != nil) {
                self.interstitial = interstitialAd;
                self.interstitial.fullScreenContentDelegate = self;
                [self.interstitial presentFromRootViewController:self];
            }
        }];
    }];
}

// MARK: - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}


@end

/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PrebidConstants.h"
#import <GoogleMobileAds/DFPInterstitial.h>
#import "InterstitialTestsViewController.h"
#import "MPInterstitialAdController.h"
#import <PrebidMobile/PrebidMobile.h>

@interface InterstitialTestsViewController () <MPInterstitialAdControllerDelegate, GADInterstitialDelegate>

@property (nonatomic, strong) MPInterstitialAdController *moPubInterstitial;
@property (nonatomic, strong) DFPInterstitial *dfpInterstitial;
@property (strong, nonatomic) NSDictionary *settings;

@end

@implementation InterstitialTestsViewController

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    _settings = settings;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *adServer = [self.settings objectForKey:kAdServer];
    self.title = [adServer stringByAppendingString:@" Interstitial"];

    if ([adServer isEqualToString:kMoPubAdServer]) {
        _moPubInterstitial = [MPInterstitialAdController  interstitialAdControllerForAdUnitId:kMoPubInterstitialAdUnitId];
        _moPubInterstitial.delegate = self;
        [PrebidMobile setBidKeywordsOnAdObject:self.moPubInterstitial withAdUnitId:kAdUnit2Id withTimeout:600 completionHandler:^{
            [self.moPubInterstitial loadAd];
        }];
    }
    else if ([adServer isEqualToString:kDFPAdServer]) {
        self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:kDFPInterstitialAdUnitId];
        self.dfpInterstitial.delegate = self;
    
        [PrebidMobile setBidKeywordsOnAdObject:self.dfpInterstitial withAdUnitId:kAdUnit2Id withTimeout:600 completionHandler:^{
            [self.dfpInterstitial loadRequest:[DFPRequest request]];
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self.moPubInterstitial showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if(self.dfpInterstitial.isReady){
        [self.dfpInterstitial presentFromRootViewController:self];
    }else {
        NSLog(@"Ad wasn't ready");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

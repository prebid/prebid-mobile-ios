/*   Copyright 2017 APPNEXUS INC
 
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

#import "BannerTestsViewController.h"
#import "Constants.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import "MPAdView.h"
#import "MPBannerCustomEvent.h"
#import "PrebidMobile/PrebidMobile.h"
#import "PrebidMobileDFPMediationAdapter/PrebidMobileDFPMediationAdapter.h"
@import FBAudienceNetwork;

@interface BannerTestsViewController () <GADBannerViewDelegate, MPAdViewDelegate, MPBannerCustomEventDelegate>

@property (strong, nonatomic) MPAdView *mopubAdView;
@property (strong, nonatomic) DFPBannerView *dfpAdView;
@property (strong, nonatomic) GADBannerView *GADBannerView;
@property (strong, nonatomic) UIView *adContainerView;
@property (strong, nonatomic) NSDictionary *settings;

@end

@implementation BannerTestsViewController

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    _settings = settings;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *adServer = [self.settings objectForKey:kAdServer];
    self.title = [adServer stringByAppendingString:@" Banner"];
    
    NSString *size = [self.settings objectForKey:kSize];
    NSArray *widthHeight = [size componentsSeparatedByString:@"x"];
    double width = [widthHeight[0] doubleValue];
    double height = [widthHeight[1] doubleValue];
    
    _adContainerView = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - width) / 2, 100, width, height)];
    [self.view addSubview:_adContainerView];
    
    if ([adServer isEqualToString:kMoPubAdServer]) {
        
        _mopubAdView = [[MPAdView alloc] initWithAdUnitId:kMoPubBannerAdUnitId
                                                size:CGSizeMake(width, height)];
        [_adContainerView addSubview:_mopubAdView];
        
        [PrebidMobile setBidKeywordsOnAdObject:self.mopubAdView withAdUnitId:kAdUnit1Id withTimeout:600 completionHandler:^{
            [self.mopubAdView loadAd];
        }];
    } else if ([adServer isEqualToString:kDFPAdServer]) {
        _dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, height))];
        _dfpAdView.adUnitID = kDFPBannerAdUnitId;
        _dfpAdView.rootViewController = self;
        _dfpAdView.delegate = self;

        [_adContainerView addSubview:_dfpAdView];
        
        [PrebidMobile setBidKeywordsOnAdObject:_dfpAdView withAdUnitId:kAdUnit1Id withTimeout:600 completionHandler:^{
            [_dfpAdView loadRequest:[DFPRequest request]];
        }];
    }
    
//    FBAdView *adView = [[FBAdView alloc] initWithPlacementID:@"1995257847363113_1997038003851764"
//                                                      adSize:kFBAdSizeHeight250Rectangle
//                                          rootViewController:(UIViewController *)[NSObject new]];
//    adView.frame = CGRectMake(0, 20, adView.bounds.size.width, adView.bounds.size.height);
//    adView.delegate = self;
//    NSString *bidPayload = @"{\"type\":\"ID\",\"bid_id\":\"4401013946958491377\",\"placement_id\":\"1995257847363113_1997038003851764\",\"sdk_version\":\"4.25.0-appnexus.bidding\",\"device_id\":\"87ECBA49-908A-428F-9DE7-4B9CED4F486C\",\"template\":7,\"payload\":\"null\"}";
//    
//    [adView loadAdWithBidPayload:bidPayload];
//    //[adView loadAd];
//    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
//    [testView addSubview:adView];
//    [_adContainerView addSubview:testView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
//    NSLog(@"Ad failed to load: %i", (int)error.code);
//}
//
//- (void)adViewDidLoad:(FBAdView *)adView {
//    [adView setFrame:CGRectMake(0, 10, 300, 250)];
//    NSLog(@"Ad was loaded and ready to be displayed");
//}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(DFPBannerView *)view {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
}

- (void)adView:(DFPBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
    NSLog(@"ERROR: %@", error);
}
//- (void)adViewDidReceiveAd:(GADBannerView *)view {
//    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
//}
//
//- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
//    NSLog(@"ERROR: %@", error);
//}

- (void)adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"MoPub: %@", NSStringFromSelector(_cmd));
    
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    NSLog(@"MoPub: %@", NSStringFromSelector(_cmd));
    
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

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

#import "BannerTestsViewController.h"
#import "Constants.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import "MPAdView.h"
#import "PrebidMobile/PrebidMobile.h"

@interface BannerTestsViewController () <GADBannerViewDelegate, MPAdViewDelegate>

@property (strong, nonatomic) MPAdView *mopubAdView;
@property (strong, nonatomic) DFPBannerView *dfpAdView;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        _mopubAdView.delegate = self;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(DFPBannerView *)view {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
}

- (void)adView:(DFPBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
}

#pragma mark MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
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

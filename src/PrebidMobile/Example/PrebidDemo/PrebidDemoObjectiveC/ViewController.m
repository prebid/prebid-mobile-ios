/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

@import GoogleMobileAds;
@import PrebidMobile;

#import "ViewController.h"
#import "MoPub.h"

@interface ViewController () <GADBannerViewDelegate,GADInterstitialDelegate,MPAdViewDelegate,MPInterstitialAdControllerDelegate>
    @property (weak, nonatomic) IBOutlet UIView *bannerView;
    @property (nonatomic, strong) DFPBannerView *dfpView;
    @property (nonatomic, strong) DFPInterstitial *dfpInterstitial;
    @property (nonatomic, strong) DFPRequest *request;
    @property (nonatomic, strong) MPAdView *mopubAdView;
    @property (nonatomic, strong) MPInterstitialAdController *mopubInterstitial;
    @property (nonatomic, strong) BannerAdUnit *bannerUnit;
    @property (nonatomic, strong) InterstitialAdUnit *interstitialUnit;
    
    @end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Prebid.shared.prebidServerAccountId = @"bfa84af2-bd16-4d35-96ad-31c6bb888df0";
    Prebid.shared.prebidServerHost = PrebidHostAppnexus;
    Prebid.shared.shareGeoLocation = true;
    // NSError* err=nil;
    // [[Prebid shared] setCustomPrebidServerWithUrl:@"" error:&err];
    // if(err == nil)
    
    if([self.adServer isEqualToString:@"DFP"] && [self.adUnit isEqualToString:@"Banner"])
    [self loadDFPBanner];
    if([self.adServer isEqualToString:@"DFP"] && [self.adUnit isEqualToString:@"Interstitial"])
    [self loadDFPInterstitial];
    if([self.adServer isEqualToString:@"MoPub"] && [self.adUnit isEqualToString:@"Banner"])
    [self loadMoPubBanner];
    if([self.adServer isEqualToString:@"MoPub"] && [self.adUnit isEqualToString:@"Interstitial"])
    [self loadMoPubInterstitial];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
    
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bannerUnit stopAutoRefresh];
}
    
    
    
-(void) loadDFPBanner {
    
    self.bannerUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    [self.bannerUnit setAutoRefreshMillisWithTime:35000];
    self.dfpView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpView.rootViewController = self;
    self.dfpView.adUnitID = @"/19968336/PrebidMobileValidator_Banner_All_Sizes";
    self.dfpView.delegate = self;
    [self.bannerView addSubview:self.dfpView];
    self.dfpView.backgroundColor = [UIColor redColor];
    self.request = [[DFPRequest alloc] init];
    self.request.testDevices = @[kDFPSimulatorID];
    
    [self.bannerUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dfpView loadRequest:self.request];
        });
    }];
}
    
-(void) loadDFPInterstitial {
    
    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4"];
    self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:@"/19968336/PrebidMobileValidator_Interstitial"];
    self.dfpInterstitial.delegate = self;
    self.request = [[DFPRequest alloc] init];
    self.request.testDevices = @[kDFPSimulatorID];
    [self.interstitialUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.dfpInterstitial loadRequest:self.request];
    }];
}
    
-(void) loadMoPubBanner {
    
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"a935eac11acd416f92640411234fbba6"];
    
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:^{
        
    }];
    self.mopubAdView = [[MPAdView alloc] initWithAdUnitId:@"a935eac11acd416f92640411234fbba6" size:CGSizeMake(300, 250)];
    self.mopubAdView.delegate = self;
    
    [self.bannerView addSubview:self.mopubAdView];
    
    self.bannerUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    // Do any additional setup after loading the view, typically from a nib.
    [self.bannerUnit fetchDemandWithAdObject:self.mopubAdView completion:^(enum ResultCode result) {         
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubAdView loadAd];
    }];
}
    
-(void) loadMoPubInterstitial {
    
    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4"];
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"2829868d308643edbec0795977f17437"];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:nil];
    self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"2829868d308643edbec0795977f17437"];
    self.mopubInterstitial.delegate = self;
    [self.interstitialUnit fetchDemandWithAdObject:self.mopubInterstitial completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubInterstitial loadAd];
    }];
    
    
}
    
#pragma mark :- DFP delegates
-(void) adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Ad received");
    
    [AdViewUtils findPrebidCreativeSize:bannerView
                                   success:^(CGSize size) {
                                       if ([bannerView isKindOfClass:[DFPBannerView class]]) {
                                           DFPBannerView *dfpBannerView = (DFPBannerView *)bannerView;
                                           
                                           [dfpBannerView resize:GADAdSizeFromCGSize(size)];
                                       }
                                   } failure:^(NSError * _Nonnull error) {
                                       NSLog(@"error: %@", error);
                                   }];

}
    
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
}
    
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if (self.dfpInterstitial.isReady)
    {
        NSLog(@"Ad ready");
        [self.dfpInterstitial presentFromRootViewController:self];
    }
    else
    {
        NSLog(@"Ad not ready");
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    NSLog(@"Ad dismissed");
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    NSLog(@"Ad presented");
}


#pragma mark :- Mopub delegates
-(void) adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"Ad received");
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad ready");
    if (self.mopubInterstitial.ready) {
        [self.mopubInterstitial showFromViewController:self];
    }
}
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad not ready");
}


@end

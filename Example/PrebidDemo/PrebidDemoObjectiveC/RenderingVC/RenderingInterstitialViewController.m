//
//  RenderingInterstitialViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingInterstitialViewController.h"

@import PrebidMobile;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileMoPubAdapters;

@import MoPubSDK;

@interface RenderingInterstitialViewController () <InterstitialAdUnitDelegate, MPInterstitialAdControllerDelegate, BannerViewDelegate, MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (nonatomic) CGSize size;
@property (nonatomic) CGRect frame;

@property (strong, nullable) BannerView *bannerView;
@property (strong, nullable) InterstitialRenderingAdUnit *interstitialAdUnit;

@property (strong, nullable) MoPubBannerAdUnit *mopubBannerAdUnit;
@property (strong, nullable) MoPubInterstitialAdUnit *mopubInterstitialAdUnit;

@property (strong, nullable) MPAdView *mopubBannerView;
@property (strong, nullable) MPInterstitialAdController *mopubInterstitial;

@end

@implementation RenderingInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.size = CGSizeMake(320, 50);
    self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    
    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppInterstitial]            ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingInterstitial]     ; break;
        case IntegrationKind_RenderingMoPub : [self loadMoPubRenderingInterstitial]   ; break;

        default:
            break;
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

#pragma mar - Load Ad

- (void)initRendering {
    PrebidRenderingConfig.shared.accountID = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    [PrebidRenderingConfig.shared setCustomPrebidServerWithUrl:@"https://prebid.openx.net/openrtb2/auction" error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
}

- (void)loadInAppInterstitial {
    
    self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"];
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadGAMRenderingInterstitial {
    
    GAMInterstitialEventHandler *eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_html_interstitial"];
    
    self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                                                                  minSizePercentage:CGSizeMake(30, 30)
                                                                       eventHandler:eventHandler];
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadMoPubRenderingInterstitial {
    
    self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"e979c52714434796909993e21c8fc8da"];
    self.mopubInterstitial.delegate = self;
    
    self.mopubInterstitialAdUnit = [[MoPubInterstitialAdUnit alloc] initWithConfigId:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"];
    [self.mopubInterstitialAdUnit fetchDemandWith:self.mopubInterstitial completion:^(FetchDemandResult result) {
        [self.mopubInterstitial loadAd];
    }];
    
}

#pragma mark - InterstitialAdUnitDelegate

- (void)interstitialDidReceiveAd:(InterstitialRenderingAdUnit *)interstitial {
    [interstitial showFrom:self];
}

- (void)interstitial:(InterstitialRenderingAdUnit *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"InApp interstitial:didFailToReceiveAdWith: %@", [error localizedDescription]);
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [interstitial showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    NSLog(@"MoPub interstitialDidFailToLoadAd: %@", [error localizedDescription]);
}

#pragma mark - BannerViewDelegate

- (UIViewController * _Nullable)bannerViewPresentationController {
    return self;
}

- (void)bannerView:(BannerView *)bannerView didReceiveAdWithAdSize:(CGSize)adSize {
    NSLog(@"InApp bannerView:didReceiveAdWithAdSize");
}

- (void)bannerView:(BannerView *)bannerView didFailToReceiveAdWith:(NSError *)error {
    NSLog(@"InApp bannerView:didFailToReceiveAdWith: %@", [error localizedDescription]);
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    NSLog(@"MoPub adViewDidLoadAd:");
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"MoPub adView:didFailToLoadAdWithError: %@", [error localizedDescription]);
}

@end



//
//  RenderingBannerViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingBannerViewController.h"

@import PrebidMobile;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileMoPubAdapters;

@import MoPubSDK;

@interface RenderingBannerViewController () <BannerViewDelegate, MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (nonatomic) CGSize size;
@property (nonatomic) CGRect frame;

@property (strong, nullable) BannerView *bannerView;
@property (strong, nullable) MediationBannerAdUnit *mopubBannerAdUnit;

@property (strong, nullable) MPAdView *mopubBannerView;

@property (strong, nullable) MoPubMediationUtils *mediationDelegate;

@end

@implementation RenderingBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.size = CGSizeMake(320, 50);
    self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    
    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppBanner]            ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingBanner]     ; break;
        case IntegrationKind_RenderingMoPub : [self loadMoPubRenderingBanner]   ; break;

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

- (void)loadInAppBanner {
    
    self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                               configID:@"50699c03-0910-477c-b4a4-911dbe2b9d42"
                                                 adSize:self.size];
    
    [self.bannerView loadAd];
    self.bannerView.delegate = self;
    
    [self.adView addSubview:self.bannerView];
}

- (void)loadGAMRenderingBanner {
    
    GAMBannerEventHandler *eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_320x50_banner"
                                                                          validGADAdSizes:@[[NSValue valueWithCGSize:self.size]]];
    
    self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                               configID:@"50699c03-0910-477c-b4a4-911dbe2b9d42"
                                                 adSize:self.size
                                           eventHandler:eventHandler];
    
    [self.bannerView loadAd];
    self.bannerView.delegate = self;
    
    [self.adView addSubview:self.bannerView];
}

- (void)loadMoPubRenderingBanner {
    self.mopubBannerView = [[MPAdView alloc] initWithAdUnitId:@"0df35635801e4110b65e762a62437698" size:self.size];
    self.mopubBannerView.delegate = self;
    [self.adView addSubview:self.mopubBannerView];
    
    self.mopubBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:@"50699c03-0910-477c-b4a4-911dbe2b9d42" size:self.size mediationDelegate:self.mediationDelegate];
    
    [self.mopubBannerAdUnit fetchDemandWith:_mopubBannerView completion:^(FetchDemandResult result) {
        [self.mopubBannerView loadAd];
    }];
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



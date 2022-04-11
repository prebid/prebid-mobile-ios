//
//  RenderingBannerViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingBannerViewController.h"

@import PrebidMobile;
@import GoogleMobileAds;
@import AppLovinSDK;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;
@import PrebidMobileMAXAdapters;

@interface RenderingBannerViewController () <BannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (nonatomic) CGSize size;
@property (nonatomic) CGRect frame;

@property (strong, nullable) BannerView *bannerView;

// AdMob
@property (nonatomic, strong) GADBannerView *gadBannerView;
@property (nonatomic, strong) AdMobMediationBannerUtils *admobMediationDelegate;
@property (nonatomic, strong) GADRequest *gadRequest;
@property (nonatomic, strong) MediationBannerAdUnit *admobBannerAdUnit;

// MAX
@property (nonatomic, strong) MAAdView *maxBannerView;
@property (nonatomic, strong) MAXMediationBannerUtils *maxMediationDelegate;
@property (nonatomic, strong) MediationBannerAdUnit *maxBannerAdUnit;

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
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingBanner]   ; break;
        case IntegrationKind_RenderingMAX   : [self loadMAXRenderingBanner]     ; break;

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
    Prebid.shared.accountID = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    [Prebid.shared setCustomPrebidServerWithUrl:@"https://prebid.openx.net/openrtb2/auction" error:nil];
    
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

- (void)loadAdMobRenderingBanner {
    self.gadBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.gadBannerView.adUnitID = @"ca-app-pub-5922967660082475/9483570409";
    self.gadRequest = [GADRequest new];
    self.admobMediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest bannerView:self.gadBannerView];
    self.admobBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:@"50699c03-0910-477c-b4a4-911dbe2b9d42" size:self.size mediationDelegate:self.admobMediationDelegate];
    
    [self.admobBannerAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        GADCustomEventExtras *extras = [GADCustomEventExtras new];
        NSDictionary *prebidExtras = [self.admobMediationDelegate getEventExtras];
        NSString *prebidExtrasLabel = AdMobConstants.PrebidAdMobEventExtrasLabel;
        [extras setExtras:prebidExtras forLabel: prebidExtrasLabel];
        [self.gadRequest registerAdNetworkExtras:extras];
        [self.gadBannerView loadRequest:self.gadRequest];
    }];
    
    [self.adView addSubview:self.gadBannerView];
}

- (void)loadMAXRenderingBanner {
    self.maxBannerView = [[MAAdView alloc] initWithAdUnitIdentifier:@"5f111f4bcd0f58ca"];
    self.maxMediationDelegate = [[MAXMediationBannerUtils alloc] initWithAdView:self.maxBannerView];
    self.maxBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:@"50699c03-0910-477c-b4a4-911dbe2b9d42" size:self.size mediationDelegate:self.maxMediationDelegate];
    
    [self.maxBannerAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        if (result != ResultCodePrebidDemandFetchSuccess) {
            return;
        }
        [self.maxBannerView loadAd];
    }];
    
    [self.adView addSubview:self.maxBannerView];
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

@end



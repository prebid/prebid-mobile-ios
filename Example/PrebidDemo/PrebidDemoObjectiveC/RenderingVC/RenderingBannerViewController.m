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
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;

@interface RenderingBannerViewController () <BannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (nonatomic) CGSize size;
@property (nonatomic) CGRect frame;

@property (strong, nullable) BannerView *bannerView;

// AdMob
@property (nonatomic, strong) GADBannerView *gadBannerView;
@property (nonatomic, strong) AdMobMediationBannerUtils *mediationDelegate;
@property (nonatomic, strong) GADRequest *gadRequest;
@property (nonatomic, strong) MediationBannerAdUnit *admobBannerAdUnit;

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
        case IntegrationKind_RenderingMAX   : break;

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
    [Prebid.shared setCustomPrebidServerWithUrl:@"https://prebid-server-test-j.prebid.org/openrtb2/auction" error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
}

- (void)loadInAppBanner {
    if (self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.size = CGSizeMake(320, 50);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        Prebid.shared.storedAuctionResponse = @"response-prebid-banner-320-50";
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:@"imp-prebid-banner-320-50"
                                                     adSize:self.size];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.size = CGSizeMake(300, 250);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        Prebid.shared.storedAuctionResponse = @"response-prebid-video-outstream";
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:@"imp-prebid-video-outstream"
                                                     adSize:self.size];
    }
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.bannerView.adUnitConfig.adSize.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.bannerView.adUnitConfig.adSize.width;
        }
    }
    
    self.bannerView.delegate = self;
    [self.adView addSubview:self.bannerView];
    [self.bannerView loadAd];
}

- (void)loadGAMRenderingBanner {
    if (self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.size = CGSizeMake(320, 50);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        Prebid.shared.storedAuctionResponse = @"response-prebid-banner-320-50";
        GAMBannerEventHandler *eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_320x50_banner"
                                                                              validGADAdSizes:@[[NSValue valueWithCGSize:self.size]]];
        
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:@"imp-prebid-banner-320-50"
                                                     adSize:self.size
                                               eventHandler:eventHandler];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.size = CGSizeMake(300, 250);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        Prebid.shared.storedAuctionResponse = @"response-prebid-video-outstream";
        GAMBannerEventHandler *eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_300x250_banner"
                                                                              validGADAdSizes:@[[NSValue valueWithCGSize:self.size]]];
        
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:@"imp-prebid-video-outstream"
                                                     adSize:self.size
                                               eventHandler:eventHandler];
    }
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.bannerView.adUnitConfig.adSize.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.bannerView.adUnitConfig.adSize.width;
        }
    }
    
    self.bannerView.delegate = self;
    [self.adView addSubview:self.bannerView];
    [self.bannerView loadAd];
}

- (void)loadAdMobRenderingBanner {
    if(self.integrationAdFormat == IntegrationAdFormat_Banner) {
        Prebid.shared.storedAuctionResponse = @"response-prebid-banner-320-50";
        self.size = CGSizeMake(320, 50);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        self.gadBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.gadRequest = [GADRequest new];
        self.mediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest bannerView:self.gadBannerView];
        self.admobBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:@"imp-prebid-banner-320-50" size:self.size mediationDelegate:self.mediationDelegate];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        Prebid.shared.storedAuctionResponse = @"response-prebid-video-outstream";
        self.size = CGSizeMake(300, 250);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
        self.gadBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.size)];
        self.gadRequest = [GADRequest new];
        self.mediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest bannerView:self.gadBannerView];
        self.admobBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:@"imp-prebid-video-outstream" size:self.size mediationDelegate:self.mediationDelegate];
    }
    
    self.gadBannerView.adUnitID = @"ca-app-pub-5922967660082475/9483570409";
    self.gadBannerView.rootViewController = self;
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.gadBannerView.adSize.size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.gadBannerView.adSize.size.width;
        }
    }
    
    [self.admobBannerAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        GADCustomEventExtras *extras = [GADCustomEventExtras new];
        NSDictionary *prebidExtras = [self.mediationDelegate getEventExtras];
        NSString *prebidExtrasLabel = AdMobConstants.PrebidAdMobEventExtrasLabel;
        [extras setExtras:prebidExtras forLabel: prebidExtrasLabel];
        [self.gadRequest registerAdNetworkExtras:extras];
        [self.adView addSubview:self.gadBannerView];
        [self.gadBannerView loadRequest:self.gadRequest];
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

@end



//
//  RenderingBannerViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingBannerViewController.h"
#import "ObjCDemoConstants.h"

@import PrebidMobile;

@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;
@import PrebidMobileMAXAdapters;

@import GoogleMobileAds;
@import AppLovinSDK;

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
    
    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppBanner]            ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingBanner]     ; break;
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingBanner]   ; break;
        // To run this example you should create your own MAX ad unit.
        case IntegrationKind_RenderingMAX   : [self loadMAXBanner]              ; break;
            
        default:
            break;
    }
    
}

#pragma mar - Load Ad

- (void)initRendering {
    Prebid.shared.accountID = ObjCDemoConstants.kPrebidAccountId;
    [Prebid.shared setCustomPrebidServerWithUrl:ObjCDemoConstants.kPrebidAWSServerURL error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
    
    if (self.integrationAdFormat == IntegrationAdFormat_Banner) {
        Prebid.shared.storedAuctionResponse = ObjCDemoConstants.kBannerDisplayStoredResponse;
        self.size = CGSizeMake(320, 50);
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        Prebid.shared.storedAuctionResponse = ObjCDemoConstants.kBannerVideoStoredResponse;
        self.size = CGSizeMake(300, 250);
    }
    
    self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
}

- (void)loadInAppBanner {
    if (self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:ObjCDemoConstants.kBannerDisplayStoredImpression
                                                     adSize:self.size];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:ObjCDemoConstants.kBannerVideoStoredImpression
                                                     adSize:self.size];
    }
    
    [self.adView addSubview:self.bannerView];
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.size.width;
        }
    }
    
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

- (void)loadGAMRenderingBanner {
    GAMBannerEventHandler *eventHandler = [[GAMBannerEventHandler alloc] initWithAdUnitID:ObjCDemoConstants.kGAMBannerAdUnitId
                                                                          validGADAdSizes:@[[NSValue valueWithCGSize:self.size]]];
    if (self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:ObjCDemoConstants.kBannerDisplayStoredImpression
                                                     adSize:self.size
                                               eventHandler:eventHandler];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.bannerView = [[BannerView alloc] initWithFrame:self.frame
                                                   configID:ObjCDemoConstants.kBannerVideoStoredImpression
                                                     adSize:self.size
                                               eventHandler:eventHandler];
    }
    
    [self.adView addSubview:self.bannerView];
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.size.width;
        }
    }
    
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

- (void)loadAdMobRenderingBanner {
    self.gadRequest = [GADRequest new];
    if(self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.gadBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.admobMediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest
                                                                                 bannerView:self.gadBannerView];
        self.admobBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:ObjCDemoConstants.kBannerDisplayStoredImpression
                                                                            size:self.size
                                                               mediationDelegate:self.admobMediationDelegate];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.gadBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(self.size)];
        self.admobMediationDelegate = [[AdMobMediationBannerUtils alloc] initWithGadRequest:self.gadRequest
                                                                                 bannerView:self.gadBannerView];
        self.admobBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:ObjCDemoConstants.kBannerVideoStoredImpression
                                                                            size:self.size
                                                               mediationDelegate:self.admobMediationDelegate];
    }
    
    self.gadBannerView.adUnitID = ObjCDemoConstants.kAdMobBannerAdUnitId;
    self.gadBannerView.rootViewController = self;
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.size.width;
        }
    }
    
    [self.admobBannerAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        GADCustomEventExtras *extras = [GADCustomEventExtras new];
        NSDictionary *prebidExtras = [self.admobMediationDelegate getEventExtras];
        NSString *prebidExtrasLabel = AdMobConstants.PrebidAdMobEventExtrasLabel;
        [extras setExtras:prebidExtras forLabel: prebidExtrasLabel];
        [self.gadRequest registerAdNetworkExtras:extras];
        [self.adView addSubview:self.gadBannerView];
        [self.gadBannerView loadRequest:self.gadRequest];
    }];
}

- (void)loadMAXBanner {
    if(self.integrationAdFormat == IntegrationAdFormat_Banner) {
        self.maxBannerView = [[MAAdView alloc] initWithAdUnitIdentifier:ObjCDemoConstants.kMAXBannerAdUnitId];
        self.maxMediationDelegate = [[MAXMediationBannerUtils alloc] initWithAdView:self.maxBannerView];
        self.maxBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:ObjCDemoConstants.kBannerDisplayStoredImpression
                                                                          size:self.size
                                                             mediationDelegate:self.maxMediationDelegate];
    } else if (self.integrationAdFormat == IntegrationAdFormat_BannerVideo) {
        self.maxBannerView = [[MAAdView alloc] initWithAdUnitIdentifier:ObjCDemoConstants.kMAXMRECAdUnitId];
        self.maxMediationDelegate = [[MAXMediationBannerUtils alloc] initWithAdView:self.maxBannerView];
        self.maxBannerAdUnit = [[MediationBannerAdUnit alloc] initWithConfigID:ObjCDemoConstants.kBannerVideoStoredImpression
                                                                          size:self.size
                                                             mediationDelegate:self.maxMediationDelegate];
        
    }
    
    self.maxBannerView.frame = self.frame;
    [self.maxBannerView setHidden:false];
    
    [self.adView addSubview:self.maxBannerView];
    
    for (NSLayoutConstraint* constraint in self.adView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.size.width;
        }
    }
    
    [self.maxBannerAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        [self.maxBannerView loadAd];
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



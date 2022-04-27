//
//  RenderingInterstitialViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingInterstitialViewController.h"
#import "ObjCDemoConstants.h"

@import PrebidMobile;

@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;
@import PrebidMobileMAXAdapters;

@import GoogleMobileAds;
@import AppLovinSDK;

@interface RenderingInterstitialViewController () <InterstitialAdUnitDelegate, GADFullScreenContentDelegate, MAAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

// In-App
@property (strong, nullable) InterstitialRenderingAdUnit *interstitialAdUnit;

// AdMob
@property (strong, nullable) MediationInterstitialAdUnit *admobInterstitialAdUnit;
@property (strong, nullable) GADInterstitialAd *interstitial;

// MAX
@property (strong, nullable) MediationInterstitialAdUnit *maxInterstitialAdUnit;
@property (strong, nullable) MAInterstitialAd *maxInterstitial;

@end

@implementation RenderingInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppInterstitial]            ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingInterstitial]     ; break;
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingInterstitial]   ; break;
        // To run this example you should create your own MAX ad unit.
        case IntegrationKind_RenderingMAX   : [self loadMAXRenderingInterstitial]     ; break;
            
        default:
            break;
    }
}

#pragma mar - Load Ad

- (void)initRendering {
    Prebid.shared.prebidServerAccountId = ObjCDemoConstants.kPrebidAccountId;
    [Prebid.shared setCustomPrebidServerWithUrl:ObjCDemoConstants.kPrebidAWSServerURL error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        Prebid.shared.storedAuctionResponse = ObjCDemoConstants.kInterstitialDisplayStoredResponse;
    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        Prebid.shared.storedAuctionResponse = ObjCDemoConstants.kInterstitialVideoStoredResponse;
    }
}

- (void)loadInAppInterstitial {
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:ObjCDemoConstants.kInterstitialDisplayStoredImpression];
    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:ObjCDemoConstants.kInterstitialVideoStoredImpression];
        self.interstitialAdUnit.adFormats = [[NSSet alloc] initWithArray:@[AdFormat.video]];
    }
    
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadGAMRenderingInterstitial {
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        GAMInterstitialEventHandler *eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:ObjCDemoConstants.kGAMInterstitialDisplayAdUnitId];
        
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:ObjCDemoConstants.kInterstitialDisplayStoredImpression
                                                                      minSizePercentage:CGSizeMake(30, 30)
                                                                           eventHandler:eventHandler];

    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        GAMInterstitialEventHandler *eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:ObjCDemoConstants.kGAMInterstitialVideoAdUnitId];
        
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:ObjCDemoConstants.kInterstitialVideoStoredImpression
                                                                      minSizePercentage:CGSizeMake(30, 30)
                                                                           eventHandler:eventHandler];
        self.interstitialAdUnit.adFormats = [[NSSet alloc] initWithArray:@[AdFormat.video]];
    }
    
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadAdMobRenderingInterstitial {
    GADRequest *request = [GADRequest new];
    AdMobMediationInterstitialUtils *mediationDelegate = [[AdMobMediationInterstitialUtils alloc] initWithGadRequest:request];
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.admobInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:ObjCDemoConstants.kInterstitialDisplayStoredImpression
                                                                           mediationDelegate:mediationDelegate];

    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.admobInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:ObjCDemoConstants.kInterstitialVideoStoredImpression
                                                                           mediationDelegate:mediationDelegate];
    }
    
    [self.admobInterstitialAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        GADCustomEventExtras *extras = [GADCustomEventExtras new];
        NSDictionary *prebidExtras = [mediationDelegate getEventExtras];
        NSString *prebidExtrasLabel = AdMobConstants.PrebidAdMobEventExtrasLabel;
        [extras setExtras:prebidExtras forLabel: prebidExtrasLabel];
        [request registerAdNetworkExtras:extras];
        [GADInterstitialAd loadWithAdUnitID:ObjCDemoConstants.kAdMobInterstitialAdUnitId
                                    request:request
                          completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AdMob interstitial failed: %@", [error localizedDescription]);
                return;
            }
            self.interstitial = interstitialAd;
            self.interstitial.fullScreenContentDelegate = self;
            [self.interstitial presentFromRootViewController:self];
        }];
    }];
}

- (void)loadMAXRenderingInterstitial {
    self.maxInterstitial = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:ObjCDemoConstants.kMAXInterstitialAdUnitId];
    MAXMediationInterstitialUtils* maxMediationDelegate = [[MAXMediationInterstitialUtils alloc] initWithInterstitialAd:self.maxInterstitial];
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.maxInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:ObjCDemoConstants.kInterstitialDisplayStoredImpression
                                                                         mediationDelegate:maxMediationDelegate];

    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.maxInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:ObjCDemoConstants.kInterstitialVideoStoredImpression
                                                                         mediationDelegate:maxMediationDelegate];
    }

    [self.maxInterstitialAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        self.maxInterstitial.delegate = self;
        [self.maxInterstitial loadAd];
    }];
}

#pragma mark - InterstitialAdUnitDelegate

- (void)interstitialDidReceiveAd:(InterstitialRenderingAdUnit *)interstitial {
    [interstitial showFrom:self];
}

- (void)interstitial:(InterstitialRenderingAdUnit *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"InApp interstitial:didFailToReceiveAdWith: %@", [error localizedDescription]);
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSLog(@"didFailToPresentFullScreenContentWithError: %@", [error localizedDescription]);
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adDidPresentFullScreenContent");
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adWillDismissFullScreenContent");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adDidDismissFullScreenContent");
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adDidRecordImpression");
}

#pragma mark - MAAdDelegate

- (void)didClickAd:(nonnull MAAd *)ad {
    NSLog(@"didClickAd:(nonnull MAAd *)ad");
}

- (void)didDisplayAd:(nonnull MAAd *)ad {
    NSLog(@"didDisplayAd:(nonnull MAAd *)ad");
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {
    NSLog(@"didFailToDisplayAd: %@", error.message);
}

- (void)didFailToLoadAdForAdUnitIdentifier:(nonnull NSString *)adUnitIdentifier withError:(nonnull MAError *)error {
    NSLog(@"didFailToLoadAdForAdUnitIdentifier: %@", error.message);
}

- (void)didHideAd:(nonnull MAAd *)ad {
    NSLog(@"didHideAd:(nonnull MAAd *)ad");
}

- (void)didLoadAd:(nonnull MAAd *)ad {
    NSLog(@"didLoadAd:(nonnull MAAd *)ad");
}

@end

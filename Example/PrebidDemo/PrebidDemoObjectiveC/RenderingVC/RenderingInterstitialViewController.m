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
@import PrebidMobileAdMobAdapters;

@import MoPubSDK;
@import GoogleMobileAds;

@interface RenderingInterstitialViewController () <InterstitialAdUnitDelegate, MPInterstitialAdControllerDelegate, GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

// In-App
@property (strong, nullable) InterstitialRenderingAdUnit *interstitialAdUnit;
// MoPub
@property (strong, nullable) MediationInterstitialAdUnit *mopubInterstitialAdUnit;
@property (strong, nullable) MPInterstitialAdController *mopubInterstitial;
// AdMob
@property (strong, nullable) MediationInterstitialAdUnit *admobInterstitialAdUnit;
@property (strong, nullable) GADInterstitialAd *interstitial;

@end

@implementation RenderingInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppInterstitial]            ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingInterstitial]     ; break;
        case IntegrationKind_RenderingMoPub : [self loadMoPubRenderingInterstitial]   ; break;
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingInterstitial]   ; break;
            
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

- (void)loadInAppInterstitial {
    
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"];
       
    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"];
        self.interstitialAdUnit.adFormat = AdFormatVideo;
    }
    
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadGAMRenderingInterstitial {
    
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {

        GAMInterstitialEventHandler *eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_html_interstitial"];
        
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                                                                      minSizePercentage:CGSizeMake(30, 30)
                                                                           eventHandler:eventHandler];

    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        GAMInterstitialEventHandler *eventHandler = [[GAMInterstitialEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_interstitial_video"];
        
        self.interstitialAdUnit = [[InterstitialRenderingAdUnit alloc] initWithConfigID:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"
                                                                      minSizePercentage:CGSizeMake(30, 30)
                                                                           eventHandler:eventHandler];
        self.interstitialAdUnit.adFormat = AdFormatVideo;
    }
    
    self.interstitialAdUnit.delegate = self;
    
    [self.interstitialAdUnit loadAd];
}

- (void)loadMoPubRenderingInterstitial {
    
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"e979c52714434796909993e21c8fc8da"];
        self.mopubInterstitial.delegate = self;
        MoPubMediationInterstitialUtils *mediationDelegate = [[MoPubMediationInterstitialUtils alloc] initWithMopubController:self.mopubInterstitial];
        self.mopubInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                                                                           mediationDelegate:mediationDelegate];
    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"7e3146fc0c744afebc8547a4567da895"];
        self.mopubInterstitial.delegate = self;
        MoPubMediationInterstitialUtils *mediationDelegate = [[MoPubMediationInterstitialUtils alloc] initWithMopubController:self.mopubInterstitial];
        self.mopubInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"
                                                                           mediationDelegate:mediationDelegate];
    }
    
    [self.mopubInterstitialAdUnit fetchDemandWithCompletion:^(FetchDemandResult result) {
        [self.mopubInterstitial loadAd];
    }];
}

- (void)loadAdMobRenderingInterstitial {
    GADRequest *request = [GADRequest new];
    AdMobMediationInterstitialUtils *mediationDelegate = [[AdMobMediationInterstitialUtils alloc] initWithGadRequest:request];
    if (self.integrationAdFormat == IntegrationAdFormat_Interstitial) {
        self.admobInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                                                                           mediationDelegate:mediationDelegate];

    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.admobInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"
                                                                           mediationDelegate:mediationDelegate];
    }
    
    [self.admobInterstitialAdUnit fetchDemandWithCompletion:^(FetchDemandResult result) {
        GADCustomEventExtras *extras = [GADCustomEventExtras new];
        NSDictionary *prebidExtras = [mediationDelegate getEventExtras];
        NSString *prebidExtrasLabel = AdMobConstants.PrebidAdMobEventExtrasLabel;
        [extras setExtras:prebidExtras forLabel: prebidExtrasLabel];
        [request registerAdNetworkExtras:extras];
        [GADInterstitialAd loadWithAdUnitID:@"ca-app-pub-5922967660082475/3383099861"
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

@end



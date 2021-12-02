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

@interface RenderingInterstitialViewController () <InterstitialAdUnitDelegate, MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (strong, nullable) InterstitialRenderingAdUnit *interstitialAdUnit;

@property (strong, nullable) MediationInterstitialAdUnit *mopubInterstitialAdUnit;

@property (strong, nullable) MPInterstitialAdController *mopubInterstitial;

@property (strong, nullable) MoPubMediationUtils *mediationDelegate;

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
        
        self.mopubInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"5a4b8dcf-f984-4b04-9448-6529908d6cb6" mediationDelegate:self.mediationDelegate];
    } else if (self.integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
        self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"7e3146fc0c744afebc8547a4567da895"];
        self.mopubInterstitial.delegate = self;
        
        self.mopubInterstitialAdUnit = [[MediationInterstitialAdUnit alloc] initWithConfigId:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"mediationDelegate:self.mediationDelegate];
    }
    
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

@end



//
//  RenderingRewardedViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingRewardedViewController.h"

@import PrebidMobile;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;

@import GoogleMobileAds;

@interface RenderingRewardedViewController () <RewardedAdUnitDelegate, InterstitialAdUnitDelegate, GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (strong, nullable) RewardedAdUnit *rewardedAdUnit;

// AdMob
@property (strong, nullable) MediationRewardedAdUnit *admobRewardedAdUnit;
@property (strong, nullable) GADRewardedAd *rewardedAd;

@end

@implementation RenderingRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppRewarded]              ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingRewarded]       ; break;
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingRewarded]     ; break;
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
    Prebid.shared.storedAuctionResponse = @"response-prebid-video-rewarded-320-480";
    [Prebid.shared setCustomPrebidServerWithUrl:@"https://prebid-server-test-j.prebid.org/openrtb2/auction" error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
}

- (void)loadInAppRewarded {
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:@"imp-prebid-video-rewarded-320-480"];
    self.rewardedAdUnit.delegate = self;
    
    [self.rewardedAdUnit loadAd];
}

- (void)loadGAMRenderingRewarded {
    GAMRewardedAdEventHandler *eventHandler = [[GAMRewardedAdEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_rewarded_video_test"];
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:@"imp-prebid-video-rewarded-320-480"
                                                      eventHandler:eventHandler];
    self.rewardedAdUnit.delegate = self;
    
    [self.rewardedAdUnit loadAd];
}

- (void)loadAdMobRenderingRewarded {
    GADRequest *request = [GADRequest new];
    AdMobMediationRewardedUtils *mediationDelegate = [[AdMobMediationRewardedUtils alloc] initWithGadRequest:request];
    
    self.admobRewardedAdUnit = [[MediationRewardedAdUnit alloc] initWithConfigId:@"imp-prebid-video-rewarded-320-480"
                                                                   mediationDelegate:mediationDelegate];
    
    [self.admobRewardedAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        [GADRewardedAd loadWithAdUnitID:@"ca-app-pub-5922967660082475/7397370641" request:request completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AdMob rewarded failed: %@", [error localizedDescription]);
                return;
            }
            self.rewardedAd = rewardedAd;
            self.rewardedAd.fullScreenContentDelegate = self;
            [self.rewardedAd presentFromRootViewController:self userDidEarnRewardHandler:^{
                NSLog(@"Reward user");
            }];
        }];
    }];
}

#pragma mark - RewardedAdUnitDelegate

- (void)rewardedAdDidReceiveAd:(RewardedAdUnit *)rewardedAd {
    [rewardedAd showFrom:self];
}

- (void)rewardedAd:(RewardedAdUnit *)rewardedAd didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"InApp rewardedAddidFailToReceiveAdWithError: %@", [error localizedDescription]);
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



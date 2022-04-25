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
@import PrebidMobileMAXAdapters;

@import GoogleMobileAds;
@import AppLovinSDK;

@interface RenderingRewardedViewController () <RewardedAdUnitDelegate, InterstitialAdUnitDelegate, GADFullScreenContentDelegate, MARewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (strong, nullable) RewardedAdUnit *rewardedAdUnit;

// AdMob
@property (strong, nullable) MediationRewardedAdUnit *admobRewardedAdUnit;
@property (strong, nullable) GADRewardedAd *gadRewarded;

// MAX
@property (strong, nullable) MediationRewardedAdUnit *maxRewardedAdUnit;
@property (strong, nullable) MARewardedAd *maxRewarded;

@end

@implementation RenderingRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppRewarded]              ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingRewarded]       ; break;
        case IntegrationKind_RenderingAdMob : [self loadAdMobRenderingRewarded]     ; break;
        // To run this example you should create your own MAX ad unit.
        case IntegrationKind_RenderingMAX   : [self loadMAXRenderingRewarded]       ; break;
        default:
            break;
    }
}

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
        [GADRewardedAd loadWithAdUnitID:@"ca-app-pub-5922967660082475/7397370641" request:request completionHandler:^(GADRewardedAd * _Nullable gadRewarded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AdMob rewarded failed: %@", [error localizedDescription]);
                return;
            }
            self.gadRewarded = gadRewarded;
            self.gadRewarded.fullScreenContentDelegate = self;
            [self.gadRewarded presentFromRootViewController:self userDidEarnRewardHandler:^{
                NSLog(@"Reward user");
            }];
        }];
    }];
}

- (void)loadMAXRenderingRewarded {
    self.maxRewarded = [MARewardedAd sharedWithAdUnitIdentifier:@"10f03680c163fb96"];
    
    MAXMediationRewardedUtils *maxMediationDelegate = [[MAXMediationRewardedUtils alloc] initWithRewardedAd:self.maxRewarded];
    self.maxRewardedAdUnit = [[MediationRewardedAdUnit alloc] initWithConfigId:@"imp-prebid-video-rewarded-320-480" mediationDelegate:maxMediationDelegate];
    
    [self.maxRewardedAdUnit fetchDemandWithCompletion:^(ResultCode result) {
        self.maxRewarded.delegate = self;
        [self.maxRewarded loadAd];
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

#pragma mark - MARewardedAdDelegate

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

- (void)didRewardUserForAd:(nonnull MAAd *)ad withReward:(nonnull MAReward *)reward {
    NSLog(@"didRewardUserForAd:(nonnull MAAd *)ad");
}

- (void)didStartRewardedVideoForAd:(nonnull MAAd *)ad {
    // Not supported.
}

- (void)didCompleteRewardedVideoForAd:(nonnull MAAd *)ad {
    // Not supported.
}

@end



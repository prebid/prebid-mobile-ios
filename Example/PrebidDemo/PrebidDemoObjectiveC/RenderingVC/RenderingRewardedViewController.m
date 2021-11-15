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
@import PrebidMobileMoPubAdapters;

@import MoPubSDK;

@interface RenderingRewardedViewController () <RewardedAdUnitDelegate, MPRewardedAdsDelegate, InterstitialAdUnitDelegate, MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (strong, nullable) RewardedAdUnit *rewardedAdUnit;
@property (strong, nullable) MoPubRewardedAdUnit *mopubRewardedAdUnit;

@end

@implementation RenderingRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initRendering];
    
    switch (self.integrationKind) {
        case IntegrationKind_InApp          : [self loadInAppRewarded]              ; break;
        case IntegrationKind_RenderingGAM   : [self loadGAMRenderingRewarded]       ; break;
        case IntegrationKind_RenderingMoPub : [self loadMoPubRenderingRewarded]     ; break;

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

- (void)loadInAppRewarded {
    
    GAMRewardedAdEventHandler *eventHandler = [[GAMRewardedAdEventHandler alloc] initWithAdUnitID:@"/21808260008/prebid_oxb_rewarded_video_test"];
    
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"
                                                      eventHandler: eventHandler];
    self.rewardedAdUnit.delegate = self;
    
    [self.rewardedAdUnit loadAd];
}

- (void)loadGAMRenderingRewarded {
    
    self.rewardedAdUnit = [[RewardedAdUnit alloc] initWithConfigID:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"];
    self.rewardedAdUnit.delegate = self;
    
    [self.rewardedAdUnit loadAd];
}

- (void)loadMoPubRenderingRewarded {
    
    self.mopubRewardedAdUnit = [[MoPubRewardedAdUnit alloc] initWithConfigId:@"12f58bc2-b664-4672-8d19-638bcc96fd5c"];
    MoPubBidInfoWrapper *bidInfoWrapper = [[MoPubBidInfoWrapper alloc] init];
    
    [self.mopubRewardedAdUnit fetchDemandWith:bidInfoWrapper completion:^(FetchDemandResult result) {
        [MPRewardedAds setDelegate:self forAdUnitId:@"7538cc74d2984c348bc14caafa3e3395"];
        
        [MPRewardedAds loadRewardedAdWithAdUnitID:@"7538cc74d2984c348bc14caafa3e3395"
                                         keywords:bidInfoWrapper.keywords
                                 userDataKeywords:nil
                                       customerId:@"testCustomerId"
                                mediationSettings:@[]
                                      localExtras:bidInfoWrapper.localExtras];
    }];
}

#pragma mark - RewardedAdUnitDelegate

- (void)rewardedAdDidReceiveAd:(RewardedAdUnit *)rewardedAd {
    [rewardedAd showFrom:self];
}

- (void)rewardedAd:(RewardedAdUnit *)rewardedAd didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"InApp rewardedAddidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

#pragma mark - MPRewardedAdsDelegate

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    [MPRewardedAds presentRewardedAdForAdUnitID:adUnitID
                             fromViewController:self
                                     withReward:nil];
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSLog(@"MoPub rewardedAdDidFailToLoadForAdUnitID: %@", [error localizedDescription]);
}

@end



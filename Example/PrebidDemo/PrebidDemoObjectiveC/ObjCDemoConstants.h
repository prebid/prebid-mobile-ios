//
//  ObjCDemoConstants.h
//  PrebidDemoObjectiveC
//
//  Created by Olena Stepaniuk on 25.04.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCDemoConstants: NSObject

@property (class, readonly) NSString *kPrebidAccountId;
@property (class, readonly) NSString *kPrebidAWSServerURL;

// Banner
@property (class, readonly) NSString *kBannerDisplayStoredResponse;
@property (class, readonly) NSString *kBannerDisplayStoredImpression;

@property (class, readonly) NSString *kBannerVideoStoredResponse;
@property (class, readonly) NSString *kBannerVideoStoredImpression;

// GAM Banner Ad Unit Ids
@property (class, readonly) NSString *kGAMBannerAdUnitId;
@property (class, readonly) NSString *kGAMOriginalBannerDisplayAdUnitId;

// AdMob Banner Ad Unit Ids
@property (class, readonly) NSString *kAdMobBannerAdUnitId;

// MAX Banner Ad Unit Ids
@property (class, readonly) NSString *kMAXBannerAdUnitId; // Display
@property (class, readonly) NSString *kMAXMRECAdUnitId; // Video Outstream

// Interstitial
@property (class, readonly) NSString *kInterstitialDisplayStoredResponse;
@property (class, readonly) NSString *kInterstitialDisplayStoredImpression;

@property (class, readonly) NSString *kInterstitialVideoStoredResponse;
@property (class, readonly) NSString *kInterstitialVideoStoredImpression;

@property (class, readonly) NSString *kInterstitialVideoVerticalStoredImpression;
@property (class, readonly) NSString *kInterstitialVideoVerticalStoredResponse;
@property (class, readonly) NSString *kInterstitialVideoLandscapeStoredResponse;

// GAM Interstitial Ad Unit Ids
@property (class, readonly) NSString *kGAMInterstitialDisplayAdUnitId;
@property (class, readonly) NSString *kGAMInterstitialVideoAdUnitId;

// AdMob Interstitial Ad Unit Ids
@property (class, readonly) NSString *kAdMobInterstitialAdUnitId;

// MAX Interstitial Ad Unit Ids
@property (class, readonly) NSString *kMAXInterstitialAdUnitId;

// Rewarded
@property (class, readonly) NSString *kRewardedStoredResponse;
@property (class, readonly) NSString *kRewardedStoredImpression;

// GAM Rewarded Ad Unit Ids
@property (class, readonly) NSString *kGAMRewardedAdUnitId;

// AdMob Rewarded Ad Unit Ids
@property (class, readonly) NSString *kAdMobRewardedAdUnitId;

// MAX Rewarded Ad Unit Ids
@property (class, readonly) NSString *kMAXRewardedAdUnitId;

// Native
@property (class, readonly) NSString *kNativeStoredResponse;
@property (class, readonly) NSString *kNativeStoredImpression;

// GAM Native Ad Unit Ids
@property (class, readonly) NSString *kGAMNativeAdUnitId;
@property (class, readonly) NSString *kGAMCustomNativeAdFormatId;

@end

NS_ASSUME_NONNULL_END

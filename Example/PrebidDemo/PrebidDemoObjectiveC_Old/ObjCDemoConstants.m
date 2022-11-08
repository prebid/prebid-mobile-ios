//
//  ObjCDemoConstants.m
//  PrebidDemoObjectiveC
//
//  Created by Olena Stepaniuk on 25.04.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjCDemoConstants.h"

@implementation ObjCDemoConstants

+(NSString *)kPrebidAccountId {
    return @"0689a263-318d-448b-a3d4-b02e8a709d9d";
}

+(NSString *)kPrebidAWSServerURL {
    return @"https://prebid-server-test-j.prebid.org/openrtb2/auction";
}

// Banner
+(NSString *)kBannerDisplayStoredResponse {
    return @"response-prebid-banner-320-50";
}

+(NSString *)kBannerDisplayStoredImpression {
    return @"imp-prebid-banner-320-50";
}

+(NSString *)kBannerVideoStoredResponse {
    return @"response-prebid-video-outstream";
}

+(NSString *)kBannerVideoStoredImpression {
    return @"imp-prebid-video-outstream";
}

// GAM Banner Ad Unit Ids
+(NSString *)kGAMBannerAdUnitId {
    return @"/21808260008/prebid_oxb_320x50_banner";
}

+(NSString *)kGAMOriginalBannerDisplayAdUnitId {
    return @"/21808260008/prebid_demo_app_original_api_banner";
}

// AdMob Banner Ad Unit Ids
+(NSString *)kAdMobBannerAdUnitId {
    return @"ca-app-pub-5922967660082475/9483570409";
}

// MAX Banner Ad Unit Ids
+(NSString *)kMAXBannerAdUnitId {
    return @"be91247472f4cd02";
}

+(NSString *)kMAXMRECAdUnitId {
    return @"566a26093516d59b";
}

// Interstitial
+(NSString *)kInterstitialDisplayStoredResponse {
    return @"response-prebid-display-interstitial-320-480";
}

+(NSString *)kInterstitialDisplayStoredImpression {
    return @"imp-prebid-display-interstitial-320-480";
}

+(NSString *)kInterstitialVideoStoredResponse {
    return @"response-prebid-video-interstitial-320-480";
}

+(NSString *)kInterstitialVideoStoredImpression {
    return @"imp-prebid-video-interstitial-320-480";
}

+(NSString *)kInterstitialVideoVerticalStoredImpression {
    return @"imp-prebid-video-interstitial-vertical";
}

+(NSString *)kInterstitialVideoVerticalStoredResponse {
    return @"response-prebid-video-interstitial-vertical-with-end-card";
}

+(NSString *)kInterstitialVideoLandscapeStoredResponse {
    return @"response-prebid-video-interstitial-landscape-with-end-card";
}

// GAM Interstitial Ad Unit Ids
+(NSString *)kGAMInterstitialDisplayAdUnitId {
    return @"/21808260008/prebid-demo-app-original-api-display-interstitial";
}

+(NSString *)kGAMInterstitialVideoAdUnitId {
    return @"/21808260008/prebid-demo-app-original-api-video-interstitial";
}

// AdMob Interstitial Ad Unit Ids
+(NSString *)kAdMobInterstitialAdUnitId {
    return @"ca-app-pub-5922967660082475/3383099861";
}

// MAX Interstitial Ad Unit Ids
+(NSString *)kMAXInterstitialAdUnitId {
    return @"8b3b31b990417275";
}

// Rewarded
+(NSString *)kRewardedStoredResponse {
    return @"response-prebid-video-rewarded-320-480";
}

+(NSString *)kRewardedStoredImpression {
    return @"imp-prebid-video-rewarded-320-480";
}

// GAM Rewarded Ad Unit Ids
+(NSString *)kGAMRewardedAdUnitId {
    return @"/21808260008/prebid_oxb_rewarded_video_test";
}

// AdMob Rewarded Ad Unit Ids
+(NSString *)kAdMobRewardedAdUnitId {
    return @"ca-app-pub-5922967660082475/7397370641";
}

// MAX Rewarded Ad Unit Ids
+(NSString *)kMAXRewardedAdUnitId {
    return @"10f03680c163fb96";
}

// Native
+(NSString *)kNativeStoredResponse {
    return @"response-prebid-banner-native-styles";
}

+(NSString *)kNativeStoredImpression {
    return @"imp-prebid-banner-native-styles";
}

// GAM Native Ad Unit Ids
+(NSString *)kGAMNativeAdUnitId {
    return @"/21808260008/apollo_custom_template_native_ad_unit";
}

+(NSString *)kGAMCustomNativeAdFormatId {
    return @"11934135";
}


@end

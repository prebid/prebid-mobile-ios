//
//  MPRewardedAdsError.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

typedef enum {
    MPRewardedAdErrorUnknown = -1,
    MPRewardedAdErrorTimeout = -1000,
    MPRewardedAdErrorAdUnitWarmingUp = -1001,
    MPRewardedAdErrorNoAdsAvailable = -1100,
    MPRewardedAdErrorInvalidCustomEvent = -1200,
    MPRewardedAdErrorMismatchingAdTypes = -1300,
    MPRewardedAdErrorAdAlreadyPlayed = -1400,
    MPRewardedAdErrorNoAdReady = -1401,
    MPRewardedAdErrorInvalidAdUnitID = -1500,
    MPRewardedAdErrorInvalidReward = -1600,
    MPRewardedAdErrorNoRewardSelected = -1601,
} MPRewardedAdsErrorCode;

extern NSString * const MoPubRewardedAdsSDKDomain;

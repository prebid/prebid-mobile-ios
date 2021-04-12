//
//  MPAdAdapterError.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MPAdAdapterErrorDomain;

// The raw values of this enum is the same as the deprecated `MPRewardedVideoErrorCode` to be backward compatible.
typedef NS_ENUM(NSInteger, MPAdAdapterErrorCode) {
    MPAdAdapterErrorCodeUnknown = -1,
    MPAdAdapterErrorCodeNoAdsAvailable = -1100,
    MPAdAdapterErrorCodeInvalidAdapter = -1200,
    MPAdAdapterErrorCodeNoAdReady = -1401,
    MPAdAdapterErrorCodeInvalidAdUnitID = -1500,
    MPAdAdapterErrorCodeInvalidReward = -1600,
    MPAdAdapterErrorCodeNoRewardSelected = -1601,
};

@interface NSError (MPAdAdapterError)

+ (NSError *)errorWithAdAdapterErrorCode:(MPAdAdapterErrorCode)code;

+ (NSError *)errorWithAdAdapterErrorCode:(MPAdAdapterErrorCode)code userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END

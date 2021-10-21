//
//  MPAdAdapterError.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdAdapterError.h"

// TODO: `MPAdAdapterErrorDomain` is going to replace the deprecated `MoPubRewardedAdsSDKDomain`.
// To be backward compatible, the value of `MPAdAdapterErrorDomain` is still "MoPubRewardedAdsSDKDomain".
// Upon removing `MoPubRewardedAdsSDKDomain`, change the value to "MPAdAdapterErrorDomain".
NSString * const MPAdAdapterErrorDomain = @"MoPubRewardedAdsSDKDomain";

@implementation NSError (MPAdAdapterError)

+ (NSError *)errorWithAdAdapterErrorCode:(MPAdAdapterErrorCode)code {
    return [NSError errorWithAdAdapterErrorCode:code userInfo:@{}];
}

+ (NSError *)errorWithAdAdapterErrorCode:(MPAdAdapterErrorCode)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:MPAdAdapterErrorDomain code:code userInfo:userInfo];
}

@end

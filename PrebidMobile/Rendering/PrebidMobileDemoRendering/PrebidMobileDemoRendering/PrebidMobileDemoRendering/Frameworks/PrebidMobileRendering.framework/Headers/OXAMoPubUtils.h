//
//  OXAMoPubUtils.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const OXAMoPubAdUnitBidKey;
FOUNDATION_EXPORT NSString * const OXAMoPubConfigIdKey;
FOUNDATION_EXPORT NSString * const OXAMoPubAdNativeResponseKey;

@class OXANativeAd;

typedef void(^OXAFindNativeAdHandler)(OXANativeAd * _Nullable, NSError * _Nullable);

/**
 A protocol for ad objects supported by Prebid MoPub adunits
 (MPAdView, MPInterstitialAdController, MPNativeAdRequestTargeting)
 */
@protocol OXAMoPubAdObjectProtocol <NSObject>
@property (nonatomic, nullable, copy) NSString *keywords;
@property (nonatomic, nullable, copy) NSDictionary *localExtras;
@end

@interface OXAMoPubUtils : NSObject

/**
 Checks that a passed object confirms to the OXAMoPubAdObjectProtocol
 @return YES if the passed object is correct, FALSE otherwise
 */
+ (BOOL)isCorrectAdObject:(NSObject *)adObject;

/**
 Finds an native ad object in the given extra dictionary.
 Calls the provided callback whith the finded native ad object or error
 */
+ (void)findNativeAd:(NSDictionary *_Nullable)extras callback:(nonnull OXAFindNativeAdHandler)completion;

@end

NS_ASSUME_NONNULL_END



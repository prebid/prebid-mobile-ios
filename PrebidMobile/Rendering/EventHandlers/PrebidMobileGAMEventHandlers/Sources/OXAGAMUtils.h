//
//  OXAGAMUtils.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;
#import <OpenXApolloSDK/OXADemandResponseInfo.h>
#import <OpenXApolloSDK/OXANativeAdDetectionListener.h>

@class DFPRequest;
@class GADNativeCustomTemplateAd;
@class GADUnifiedNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface OXAGAMUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedUtils;

- (void)prepareRequest:(DFPRequest *)request demandResponseInfo:(OXADemandResponseInfo *)demandResponseInfo;
- (void)findNativeAdInCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd
             nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener;
- (void)findNativeAdInUnifiedNativeAd:(GADUnifiedNativeAd *)unifiedNativeAd
            nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener;

@end

NS_ASSUME_NONNULL_END

//
//  PBMGAMUtils.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import <PrebidMobileRendering/PBMDemandResponseInfo.h>
#import <PrebidMobileRendering/PBMNativeAdDetectionListener.h>

@class DFPRequest;
@class GADNativeCustomTemplateAd;
@class GADUnifiedNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedUtils;

- (void)prepareRequest:(DFPRequest *)request demandResponseInfo:(PBMDemandResponseInfo *)demandResponseInfo;
- (void)findNativeAdInCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd
             nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener;
- (void)findNativeAdInUnifiedNativeAd:(GADUnifiedNativeAd *)unifiedNativeAd
            nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener;

@end

NS_ASSUME_NONNULL_END

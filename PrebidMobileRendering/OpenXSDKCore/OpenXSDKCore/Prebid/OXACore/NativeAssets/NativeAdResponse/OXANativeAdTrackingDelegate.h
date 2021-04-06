//
//  OXANativeAdTrackingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeEventType.h"

@class OXANativeAd;

NS_ASSUME_NONNULL_BEGIN

@protocol OXANativeAdTrackingDelegate <NSObject>

@optional
- (void)nativeAdDidLogClick:(OXANativeAd *)nativeAd;
- (void)nativeAd:(OXANativeAd *)nativeAd didLogEvent:(OXANativeEventType)nativeEvent;

@end

NS_ASSUME_NONNULL_END

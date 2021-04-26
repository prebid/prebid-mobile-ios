//
//  PBMNativeAdTrackingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeEventType.h"

@class PBMNativeAd;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMNativeAdTrackingDelegate <NSObject>

@optional
- (void)nativeAdDidLogClick:(PBMNativeAd *)nativeAd;
- (void)nativeAd:(PBMNativeAd *)nativeAd didLogEvent:(PBMNativeEventType)nativeEvent;

@end

NS_ASSUME_NONNULL_END

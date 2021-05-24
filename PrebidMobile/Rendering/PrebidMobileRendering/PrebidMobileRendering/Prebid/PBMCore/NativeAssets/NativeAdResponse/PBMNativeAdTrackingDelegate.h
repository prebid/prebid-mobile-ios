//
//  PBMNativeAdTrackingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeEventType.h"

@class NativeAd;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMNativeAdTrackingDelegate <NSObject>

@optional
- (void)nativeAdDidLogClick:(NativeAd *)nativeAd;
- (void)nativeAd:(NativeAd *)nativeAd didLogEvent:(PBMNativeEventType)nativeEvent;

@end

NS_ASSUME_NONNULL_END

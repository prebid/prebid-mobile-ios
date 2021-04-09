//
//  OXAMoPubNativeAdUtils.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import <MoPub/MoPub.h>

#import <OpenXApolloSDK/OXANativeAdDetectionListener.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXAMoPubNativeAdUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedUtils;

- (void)prepareAdObject:(id)adObject;

- (void)findNativeAdIn:(MPNativeAd *)nativeAd nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener;

@end

NS_ASSUME_NONNULL_END

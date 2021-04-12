//
//  OXAApolloNativeAdAdapter.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPub/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@class OXANativeAd;

@interface OXAMoPubNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

@property (nonatomic, strong, readonly) OXANativeAd *nativeAd;

- (instancetype)initWithOXANativeAd:(OXANativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END

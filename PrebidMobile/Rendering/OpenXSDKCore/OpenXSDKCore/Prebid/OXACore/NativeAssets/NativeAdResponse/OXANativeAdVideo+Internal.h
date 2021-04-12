//
//  OXANativeAdVideo+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdVideo.h"
#import "OXANativeAdAsset+FromMarkup.h"

#import "OXANativeAdMediaHooks.h"

@class OXAMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdVideo ()

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
                                       nativeAdHooks:(OXANativeAdMediaHooks *)nativeAdHooks
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

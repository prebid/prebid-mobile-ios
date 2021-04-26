//
//  PBMNativeAdVideo+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdVideo.h"
#import "PBMNativeAdAsset+FromMarkup.h"

#import "PBMNativeAdMediaHooks.h"

@class PBMMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdVideo ()

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                       nativeAdHooks:(PBMNativeAdMediaHooks *)nativeAdHooks
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

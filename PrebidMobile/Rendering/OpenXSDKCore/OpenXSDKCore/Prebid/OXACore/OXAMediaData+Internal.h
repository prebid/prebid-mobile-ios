//
//  OXAMediaData+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAMediaData.h"
#import "OXANativeAdMarkupAsset.h"
#import "OXANativeAdMediaHooks.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAMediaData ()

/// Raw (complete and unmodified) asset data from the response.
@property (nonatomic, strong, readonly) OXANativeAdMarkupAsset *mediaAsset;

/// Serves to provide the information available at NativeAd's level to the MediaView
/// e.g. viewController for presenting modals, effective (potentially parent) link object, etc.
@property (nonatomic, strong, readonly) OXANativeAdMediaHooks *nativeAdHooks;

- (instancetype)initWithMediaAsset:(OXANativeAdMarkupAsset *)mediaAsset
                     nativeAdHooks:(OXANativeAdMediaHooks *)nativeAdHooks;

@end

NS_ASSUME_NONNULL_END

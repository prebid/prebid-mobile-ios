//
//  PBMMediaData+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMMediaData.h"
#import "PBMNativeAdMarkupAsset.h"
#import "PBMNativeAdMediaHooks.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMMediaData ()

/// Raw (complete and unmodified) asset data from the response.
@property (nonatomic, strong, readonly) PBMNativeAdMarkupAsset *mediaAsset;

/// Serves to provide the information available at NativeAd's level to the MediaView
/// e.g. viewController for presenting modals, effective (potentially parent) link object, etc.
@property (nonatomic, strong, readonly) PBMNativeAdMediaHooks *nativeAdHooks;

- (instancetype)initWithMediaAsset:(PBMNativeAdMarkupAsset *)mediaAsset
                     nativeAdHooks:(PBMNativeAdMediaHooks *)nativeAdHooks;

@end

NS_ASSUME_NONNULL_END

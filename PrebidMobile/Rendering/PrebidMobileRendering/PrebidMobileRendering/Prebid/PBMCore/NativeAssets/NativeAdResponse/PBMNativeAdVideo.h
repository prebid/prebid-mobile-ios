//
//  PBMNativeAdVideo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdAsset.h"

@class PBMMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdVideo : PBMNativeAdAsset

/// Media data describing this asset
@property (nonatomic, strong, nonnull, readonly) PBMMediaData *mediaData;

@end

NS_ASSUME_NONNULL_END

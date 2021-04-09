//
//  OXANativeAdVideo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAsset.h"

@class OXAMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdVideo : OXANativeAdAsset

/// Media data describing this asset
@property (nonatomic, strong, nonnull, readonly) OXAMediaData *mediaData;

@end

NS_ASSUME_NONNULL_END

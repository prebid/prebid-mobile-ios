//
//  OXANativeAdImage.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAsset.h"
#import "OXAImageAssetType.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdImage : OXANativeAdAsset

/// [Integer]
/// The type of image element being submitted from the Image Asset Types table.
/// Required for assetsurl or dcourl responses, not required for embedded asset responses.
@property (nonatomic, strong, nullable, readonly) NSNumber *imageType;

/// URL of the image asset.
@property (nonatomic, strong, nonnull, readonly) NSString *url;

/// [Integer]
/// Width of the image in pixels.
/// Recommended for embedded asset responses.
/// Required for assetsurl/dcourlresponses if multiple assets of same type submitted.
@property (nonatomic, strong, nullable, readonly) NSNumber *width;

/// [Integer]
/// Height of the image in pixels.
/// Recommended for embedded asset responses.
/// Required for assetsurl/dcourl responses if multiple assets of same type submitted.
@property (nonatomic, strong, nullable, readonly) NSNumber *height;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *imageExt;

@end

NS_ASSUME_NONNULL_END

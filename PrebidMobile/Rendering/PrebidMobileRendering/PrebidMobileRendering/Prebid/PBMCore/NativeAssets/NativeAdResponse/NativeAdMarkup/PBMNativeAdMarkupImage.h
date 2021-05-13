//
//  PBMNativeAdMarkupImage.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMJsonDecodable.h"
#import "PBMImageAssetType.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupImage : NSObject <PBMJsonDecodable>

/// [Integer]
/// The type of image element being submitted from the Image Asset Types table. 
/// Required for assetsurl or dcourl responses, not required for embedded asset responses.
@property (nonatomic, strong, nullable) NSNumber *imageType;

/// URL of the image asset.
@property (nonatomic, copy, nullable) NSString *url;

/// [Integer]
/// Width of the image in pixels.
/// Recommended for embedded asset responses.
/// Required for assetsurl/dcourlresponses if multiple assets of same type submitted.
@property (nonatomic, strong, nullable) NSNumber *width;

/// [Integer]
/// Height of the image in pixels.
/// Recommended for embedded asset responses.
/// Required for assetsurl/dcourl responses if multiple assets of same type submitted.
@property (nonatomic, strong, nullable) NSNumber *height;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithUrl:(nullable NSString *)url;

@end

NS_ASSUME_NONNULL_END
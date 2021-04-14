//
//  OXANativeAssetImage.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAssetImage : OXANativeAsset

/// [Integer]
/// Type ID of the image element supported by the publisher. The publisher can display this information in an appropriate format.
@property (nonatomic, strong, nullable) NSNumber *imageType;

/// [Integer]
/// Width of the image in pixels.
@property (nonatomic, strong, nullable) NSNumber *width;

/// [Recommended]
/// [Integer]
/// The minimum requested width of the image in pixels.
/// This option should be used for any rescaling of images by the client.
/// Either w or wmin should be transmitted.
/// If only w is included, it should be considered an exact requirement.
@property (nonatomic, strong, nullable) NSNumber *widthMin;

/// [Integer]
/// Height of the image in pixels.
@property (nonatomic, strong, nullable) NSNumber *height;

/// [Recommended]
/// [Integer]
/// The minimum requested height of the image in pixels.
/// This option should be used for any rescaling of images by the client.
/// Either h or hmin should be transmitted.
/// If only h is included, it should be considered an exact requirement.
@property (nonatomic, strong, nullable) NSNumber *heightMin;

/// Whitelist of content MIME types supported.
/// Popular MIME types include, but are not limited to “image/jpg” “image/gif”.
/// Each implementing Exchange should have their own list of supported types in the integration docs.
/// See Wikipedia's MIME page for more information and links to all IETF RFCs.
/// If blank, assume all types are allowed.
@property (nonatomic, copy, nullable) NSArray<NSString *> *mimeTypes;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *imageExt;

- (BOOL)setImageExt:(nullable NSDictionary<NSString *, id> *)imageExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// MARK: - Lifecycle

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

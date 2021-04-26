//
//  PBMNativeAssetVideo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAssetVideo : PBMNativeAsset

/// [Required]
/// Content MIME types supported.
/// Popular MIME types include, but are not limited to
/// “video/x-ms- wmv” for Windows Media, and
/// “video/x-flv” for Flash Video, or “video/mp4”.
/// Note that native frequently does not support flash.
@property (nonatomic, copy) NSArray<NSString *> *mimeTypes;

/// [Required]
/// Minimum video ad duration in seconds.
@property (nonatomic, assign) NSInteger minDuration;

/// [Required]
/// Maximum video ad duration in seconds.
@property (nonatomic, assign) NSInteger maxDuration;

/// [Required]
/// An array of video protocols the integers publisher can accept in the bid response.
/// See OpenRTB Table ‘Video Bid Response Protocols’ for a list of possible values.
@property (nonatomic, copy) NSArray<NSNumber *> *protocols;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *videoExt;

- (BOOL)setVideoExt:(nullable NSDictionary<NSString *, id> *)videoExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// MARK: - Lifecycle

- (instancetype)initWithMimeTypes:(NSArray<NSString *> *)mimeTypes
                      minDuration:(NSInteger)minDuration
                      maxDuration:(NSInteger)maxDuration
                        protocols:(NSArray<NSNumber *> *)protocols NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

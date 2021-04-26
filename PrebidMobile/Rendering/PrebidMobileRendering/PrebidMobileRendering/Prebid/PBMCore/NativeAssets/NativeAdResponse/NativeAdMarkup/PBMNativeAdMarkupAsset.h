//
//  PBMNativeAdMarkupAsset.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdMarkupData.h"
#import "PBMNativeAdMarkupImage.h"
#import "PBMNativeAdMarkupLink.h"
#import "PBMNativeAdMarkupTitle.h"
#import "PBMNativeAdMarkupVideo.h"

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupAsset : NSObject <PBMJsonDecodable>

/// [Integer]
/// Optional if assetsurl/dcourl is being used
/// Required if embedded asset is being used.
@property (nonatomic, strong, nullable) NSNumber *assetID;

/// [Integer]
/// Set to 1 if asset is required (bidder requires it to be displayed)
@property (nonatomic, strong, nullable) NSNumber *required;

/// Title object for title assets.
/// See TitleObject definition.
@property (nonatomic, strong, nullable) PBMNativeAdMarkupTitle *title;

/// Image object for image assets.
/// See ImageObject definition.
@property (nonatomic, strong, nullable) PBMNativeAdMarkupImage *img;

/// Video object for video assets.
/// See Video response object definition.
/// Note that in-stream video ads are not part of Native.
/// Native ads may contain a video as the ad creative itself.
@property (nonatomic, strong, nullable) PBMNativeAdMarkupVideo *video;

/// Data object for ratings, prices etc.
@property (nonatomic, strong, nullable) PBMNativeAdMarkupData *data;

/// Link object for call to actions.
/// The link object applies if the asset item is activated (clicked).
/// If there is no link object on the asset, the parent link object on the bid response applies.
@property (nonatomic, strong, nullable) PBMNativeAdMarkupLink *link;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithData:(PBMNativeAdMarkupData *)data;
- (instancetype)initWithImage:(PBMNativeAdMarkupImage *)image;
- (instancetype)initWithTitle:(PBMNativeAdMarkupTitle *)title;
- (instancetype)initWithVideo:(PBMNativeAdMarkupVideo *)video;

@end

NS_ASSUME_NONNULL_END

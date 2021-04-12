//
//  OXANativeAdMarkupAsset.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupData.h"
#import "OXANativeAdMarkupImage.h"
#import "OXANativeAdMarkupLink.h"
#import "OXANativeAdMarkupTitle.h"
#import "OXANativeAdMarkupVideo.h"

#import "OXAJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdMarkupAsset : NSObject <OXAJsonDecodable>

/// [Integer]
/// Optional if assetsurl/dcourl is being used
/// Required if embedded asset is being used.
@property (nonatomic, strong, nullable) NSNumber *assetID;

/// [Integer]
/// Set to 1 if asset is required (bidder requires it to be displayed)
@property (nonatomic, strong, nullable) NSNumber *required;

/// Title object for title assets.
/// See TitleObject definition.
@property (nonatomic, strong, nullable) OXANativeAdMarkupTitle *title;

/// Image object for image assets.
/// See ImageObject definition.
@property (nonatomic, strong, nullable) OXANativeAdMarkupImage *img;

/// Video object for video assets.
/// See Video response object definition.
/// Note that in-stream video ads are not part of Native.
/// Native ads may contain a video as the ad creative itself.
@property (nonatomic, strong, nullable) OXANativeAdMarkupVideo *video;

/// Data object for ratings, prices etc.
@property (nonatomic, strong, nullable) OXANativeAdMarkupData *data;

/// Link object for call to actions.
/// The link object applies if the asset item is activated (clicked).
/// If there is no link object on the asset, the parent link object on the bid response applies.
@property (nonatomic, strong, nullable) OXANativeAdMarkupLink *link;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithData:(OXANativeAdMarkupData *)data;
- (instancetype)initWithImage:(OXANativeAdMarkupImage *)image;
- (instancetype)initWithTitle:(OXANativeAdMarkupTitle *)title;
- (instancetype)initWithVideo:(OXANativeAdMarkupVideo *)video;

@end

NS_ASSUME_NONNULL_END

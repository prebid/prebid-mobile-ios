//
//  OXANativeAdAsset.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdAsset : NSObject

/// [Integer]
/// Optional if assetsurl/dcourl is being used
/// Required if embedded asset is being used.
@property (nonatomic, strong, nullable, readonly) NSNumber *assetID;

/// [Integer]
/// Set to 1 if asset is required (bidder requires it to be displayed)
@property (nonatomic, strong, nullable, readonly) NSNumber *required;

// /// Link object for call to actions.
// /// The link object applies if the asset item is activated (clicked).
// /// If there is no link object on the asset, the parent link object on the bid response applies.
// @property (nonatomic, strong, nullable, readonly) OXANativeAdMarkupLink *link;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *assetExt;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

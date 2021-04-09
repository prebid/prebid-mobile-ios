//
//  OXANativeAdTitle.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdTitle : OXANativeAdAsset

/// The text associated with the text element.
@property (nonatomic, strong, nonnull, readonly) NSString *text;

/// [Integer]
/// The length of the title being provided.
/// Required if using assetsurl/dcourl representation, optional if using embedded asset representation.
@property (nonatomic, strong, nullable, readonly) NSNumber *length;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *titleExt;

@end

NS_ASSUME_NONNULL_END

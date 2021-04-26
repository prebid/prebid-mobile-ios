//
//  PBMNativeAdMarkupTitle.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupTitle : NSObject <PBMJsonDecodable>

/// The text associated with the text element.
@property (nonatomic, copy, nullable) NSString *text;

/// [Integer]
/// The length of the title being provided.
/// Required if using assetsurl/dcourl representation, optional if using embedded asset representation.
@property (nonatomic, strong, nullable) NSNumber *length;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithText:(nullable NSString *)text;

@end

NS_ASSUME_NONNULL_END

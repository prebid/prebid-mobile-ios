//
//  OXANativeAdData.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAsset.h"
#import "OXADataAssetType.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdData : OXANativeAdAsset

/// The type of data element being submitted from the Data Asset Types table.
/// Required for assetsurl/dcourl responses, not required for embedded asset responses.
@property (nonatomic, strong, nullable, readonly) NSNumber *dataType;

/// [Integer]
/// The length of the data element being submitted.
/// Required for assetsurl/dcourl responses, not required for embedded asset responses.
/// Where applicable, must comply with the recommended maximum lengths in the Data Asset Types table.
@property (nonatomic, strong, nullable, readonly) NSNumber *length;

/// The formatted string of data to be displayed.
/// Can contain a formatted value such as “5 stars” or “$10” or “3.4 stars out of 5”.
@property (nonatomic, strong, nonnull, readonly) NSString *value;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *dataExt;

@end

NS_ASSUME_NONNULL_END

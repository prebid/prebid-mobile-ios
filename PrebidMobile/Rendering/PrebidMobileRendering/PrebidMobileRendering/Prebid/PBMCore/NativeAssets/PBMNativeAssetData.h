//
//  PBMNativeAssetData.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"
#import "PBMDataAssetType.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAssetData : PBMNativeAsset

/// [Required]
/// [Integer]
/// Type ID of the element supported by the publisher.
/// The publisher can display this information in an appropriate format. See Data Asset Types table for commonly used examples.
@property (nonatomic, assign) PBMDataAssetType dataType;

/// [Integer]
/// Maximum length of the text in the element’s response.
@property (nonatomic, strong, nullable) NSNumber *length;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *dataExt;

- (BOOL)setDataExt:(nullable NSDictionary<NSString *, id> *)dataExt
             error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// MARK: - Lifecycle

- (instancetype)initWithDataType:(PBMDataAssetType)dataType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

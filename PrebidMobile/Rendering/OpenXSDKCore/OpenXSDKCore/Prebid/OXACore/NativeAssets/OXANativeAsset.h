//
//  OXANativeAsset.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAsset : NSObject <NSCopying>

/// [Required]
/// [Integer]
/// Unique asset ID, assigned by exchange. Typically a counter for the array.
/// Assigned by SDK.
@property (nonatomic, strong, nullable, readonly) NSNumber *assetID;

/// [Integer]
/// Set to 1 if asset is required (exchange will not accept a bid without it)
@property (nonatomic, strong, nullable) NSNumber *required;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *assetExt;

- (BOOL)setAssetExt:(nullable NSDictionary<NSString *, id> *)assetExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// MARK: - Lifecycle

/// OXANativeAsset class should not be instantialted directly, instantiate subclasses instead.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

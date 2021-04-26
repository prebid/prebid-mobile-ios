//
//  PBMNativeAssetTitle.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAssetTitle : PBMNativeAsset

/// [Required]
/// [Integer]
/// Maximum length of the text in the title element.
/// Recommended to be 25, 90, or 140.
@property (nonatomic, assign) NSInteger length;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *titleExt;

- (BOOL)setTitleExt:(nullable NSDictionary<NSString *, id> *)titleExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// MARK: - Lifecycle

- (instancetype)initWithLength:(NSInteger)length NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

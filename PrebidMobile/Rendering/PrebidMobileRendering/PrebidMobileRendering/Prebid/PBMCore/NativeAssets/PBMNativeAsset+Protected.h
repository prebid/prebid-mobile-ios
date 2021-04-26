//
//  PBMNativeAsset+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"

#import "PBMConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAsset()

@property (nonatomic, copy, nullable, readonly) PBMJsonDictionary *childExt;

- (instancetype)initWithChildType:(NSString *)childType;

- (BOOL)setChildExt:(nullable NSDictionary<NSString *, id> *)childExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;

// MARK: - Serialization

- (void)appendAssetProperties:(PBMMutableJsonDictionary *)jsonDictionary;
- (void)appendChildProperties:(PBMMutableJsonDictionary *)jsonDictionary;

// MARK: - Cloning

- (void)copyOptionalPropertiesInto:(PBMNativeAsset *)clone;

@end

NS_ASSUME_NONNULL_END

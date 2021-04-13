//
//  OXANativeAsset+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAsset.h"

#import "OXMConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAsset()

@property (nonatomic, copy, nullable, readonly) OXMJsonDictionary *childExt;

- (instancetype)initWithChildType:(NSString *)childType;

- (BOOL)setChildExt:(nullable NSDictionary<NSString *, id> *)childExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;

// MARK: - Serialization

- (void)appendAssetProperties:(OXMMutableJsonDictionary *)jsonDictionary;
- (void)appendChildProperties:(OXMMutableJsonDictionary *)jsonDictionary;

// MARK: - Cloning

- (void)copyOptionalPropertiesInto:(OXANativeAsset *)clone;

@end

NS_ASSUME_NONNULL_END

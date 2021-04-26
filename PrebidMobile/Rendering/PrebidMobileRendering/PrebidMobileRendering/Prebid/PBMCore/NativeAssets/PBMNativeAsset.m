//
//  PBMNativeAsset.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"
#import "PBMNativeAsset+Internal.h"
#import "PBMNativeAsset+Protected.h"

#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMLog.h"
#import "PBMMacros.h"

#import "NSDictionary+PBMExtensions.h"
#import "NSDictionary+PBMORTBNativeExt.h"
#import "NSNumber+PBMORTBNative.h"

@interface PBMNativeAsset()
@property (nonatomic, strong) NSString *childType;
@end


@implementation PBMNativeAsset

- (instancetype)init {
    PBMAssertExt(NO, @"PBMNativeAsset class should not be instantialted directly, instantiate subclasses instead.");
    return nil;
}

- (instancetype)initWithChildType:(NSString *)childType {
    if (!(self = [super init])) {
        return nil;
    }
    _childType = [childType copy];
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMNativeAsset * const result = [[PBMNativeAsset alloc] initWithChildType:self.childType];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(PBMNativeAsset *)clone {
    clone.assetID = self.assetID;
    clone.required = self.required;
    clone.assetExt = self.assetExt;
    clone.childExt = self.childExt;
}

- (void)setChildExt:(PBMJsonDictionary * _Nullable)childExt {
    _childExt = childExt;
}

- (void)setAssetExt:(NSDictionary<NSString *,id> * _Nullable)assetExt {
    _assetExt = assetExt;
}

// MARK: - Ext properties

- (BOOL)setAssetExt:(nullable NSDictionary<NSString *, id> *)assetExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    PBMJsonDictionary * const newExt = [assetExt unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _assetExt = newExt;
    return YES;
}

- (BOOL)setChildExt:(nullable NSDictionary<NSString *, id> *)childExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    PBMJsonDictionary * const newExt = [childExt unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _childExt = newExt;
    return YES;
}

// MARK: - PBMJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [PBMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable PBMJsonDictionary *)jsonDictionary {
    PBMMutableJsonDictionary * const assetProperties = [[PBMMutableJsonDictionary alloc] init];
    [self appendAssetProperties:assetProperties];
    PBMMutableJsonDictionary * const childProperties = [[PBMMutableJsonDictionary alloc] init];
    [self appendChildProperties:childProperties];
    assetProperties[self.childType] = childProperties.count ? childProperties : nil;
    return assetProperties;
}

// MARK: - Protected

- (void)appendAssetProperties:(PBMMutableJsonDictionary *)jsonDictionary {
    jsonDictionary[@"id"] = self.assetID;
    jsonDictionary[@"required"] = self.required.integerNumber;
    jsonDictionary[@"ext"] = self.assetExt;
};

- (void)appendChildProperties:(PBMMutableJsonDictionary *)jsonDictionary {
    jsonDictionary[@"ext"] = self.childExt;
}

@end

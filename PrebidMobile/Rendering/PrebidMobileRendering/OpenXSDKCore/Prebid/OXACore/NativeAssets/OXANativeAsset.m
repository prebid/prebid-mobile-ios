//
//  OXANativeAsset.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAsset.h"
#import "OXANativeAsset+Internal.h"
#import "OXANativeAsset+Protected.h"

#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMLog.h"
#import "OXMMacros.h"

#import "NSDictionary+OxmExtensions.h"
#import "NSDictionary+OXAORTBNativeExt.h"
#import "NSNumber+OXAORTBNative.h"

@interface OXANativeAsset()
@property (nonatomic, strong) NSString *childType;
@end


@implementation OXANativeAsset

- (instancetype)init {
    OXAAssert(NO, @"OXANativeAsset class should not be instantialted directly, instantiate subclasses instead.");
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
    OXANativeAsset * const result = [[OXANativeAsset alloc] initWithChildType:self.childType];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(OXANativeAsset *)clone {
    clone.assetID = self.assetID;
    clone.required = self.required;
    clone.assetExt = self.assetExt;
    clone.childExt = self.childExt;
}

- (void)setChildExt:(OXMJsonDictionary * _Nullable)childExt {
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
    OXMJsonDictionary * const newExt = [assetExt unserializedCopyWithError:&localError];
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
    OXMJsonDictionary * const newExt = [childExt unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _childExt = newExt;
    return YES;
}

// MARK: - OXAJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [OXMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable OXMJsonDictionary *)jsonDictionary {
    OXMMutableJsonDictionary * const assetProperties = [[OXMMutableJsonDictionary alloc] init];
    [self appendAssetProperties:assetProperties];
    OXMMutableJsonDictionary * const childProperties = [[OXMMutableJsonDictionary alloc] init];
    [self appendChildProperties:childProperties];
    assetProperties[self.childType] = childProperties.count ? childProperties : nil;
    return assetProperties;
}

// MARK: - Protected

- (void)appendAssetProperties:(OXMMutableJsonDictionary *)jsonDictionary {
    jsonDictionary[@"id"] = self.assetID;
    jsonDictionary[@"required"] = self.required.integerNumber;
    jsonDictionary[@"ext"] = self.assetExt;
};

- (void)appendChildProperties:(OXMMutableJsonDictionary *)jsonDictionary {
    jsonDictionary[@"ext"] = self.childExt;
}

@end

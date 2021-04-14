//
//  OXANativeAssetData.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAssetData.h"
#import "OXANativeAsset+Protected.h"
#import "NSNumber+OXAORTBNative.h"

@implementation OXANativeAssetData

- (instancetype)initWithDataType:(OXADataAssetType)dataType {
    if (!(self = [super initWithChildType:@"data"])) {
        return nil;
    }
    _dataType = dataType;
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    OXANativeAssetData * const result = [[OXANativeAssetData alloc] initWithDataType:self.dataType];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(OXANativeAsset *)clone {
    [super copyOptionalPropertiesInto:clone];
    if ([clone isKindOfClass:self.class]) {
        OXANativeAssetData * const dataClone = (OXANativeAssetData *)clone;
        dataClone.length = self.length;
    }
}

// MARK: - Data Ext

- (NSDictionary<NSString *,id> *)dataExt {
    return self.childExt;
}

- (BOOL)setDataExt:(nullable NSDictionary<NSString *, id> *)dataExt
             error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [self setChildExt:dataExt error:error];
}

// MARK: - Protected

- (void)appendChildProperties:(OXMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"type"] = @(self.dataType);
    jsonDictionary[@"len"] = self.length.integerNumber;
}

@end

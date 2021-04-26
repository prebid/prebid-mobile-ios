//
//  PBMNativeAssetData.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAssetData.h"
#import "PBMNativeAsset+Protected.h"
#import "NSNumber+PBMORTBNative.h"

@implementation PBMNativeAssetData

- (instancetype)initWithDataType:(PBMDataAssetType)dataType {
    if (!(self = [super initWithChildType:@"data"])) {
        return nil;
    }
    _dataType = dataType;
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMNativeAssetData * const result = [[PBMNativeAssetData alloc] initWithDataType:self.dataType];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(PBMNativeAsset *)clone {
    [super copyOptionalPropertiesInto:clone];
    if ([clone isKindOfClass:self.class]) {
        PBMNativeAssetData * const dataClone = (PBMNativeAssetData *)clone;
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

- (void)appendChildProperties:(PBMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"type"] = @(self.dataType);
    jsonDictionary[@"len"] = self.length.integerNumber;
}

@end

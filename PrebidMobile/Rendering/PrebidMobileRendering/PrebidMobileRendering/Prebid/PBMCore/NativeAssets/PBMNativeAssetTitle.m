//
//  PBMNativeAssetTitle.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAssetTitle.h"
#import "PBMNativeAsset+Protected.h"

@implementation PBMNativeAssetTitle

- (instancetype)initWithLength:(NSInteger)length {
    if (!(self = [super initWithChildType:@"title"])) {
        return nil;
    }
    _length = length;
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMNativeAssetTitle * const result = [[PBMNativeAssetTitle alloc] initWithLength:self.length];
    [self copyOptionalPropertiesInto:result];
    return result;
}

// MARK: - Title Ext

- (NSDictionary<NSString *,id> *)titleExt {
    return self.childExt;
}

- (BOOL)setTitleExt:(nullable NSDictionary<NSString *, id> *)titleExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [self setChildExt:titleExt error:error];
}

// MARK: - Protected

- (void)appendChildProperties:(PBMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"len"] = @(self.length);
}

@end

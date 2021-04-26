//
//  PBMORTBAbstractResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstractResponse.h"
#import "PBMORTBAbstractResponse+Protected.h"

#import "PBMLog.h"

@implementation PBMORTBAbstractResponse

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser {
    if (!(self = [super init])) {
        return nil;
    }
    PBMJsonDictionary * const rawExt = jsonDictionary[@"ext"];
    if (rawExt && extParser) {
        _ext = extParser(rawExt);
    }
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    [self populateJsonDictionary:ret];
    return ret;
}

- (void)populateJsonDictionary:(nonnull PBMMutableJsonDictionary *)jsonDictionary {
    PBMJsonDictionary * const extDic = self.extAsJsonDictionary;
    if (extDic) {
        jsonDictionary[@"ext"] = extDic;
    }
}

- (PBMJsonDictionary *)extAsJsonDictionary {
    if (!self.ext) {
        return nil;
    }
    if ([self.ext isKindOfClass:[PBMORTBAbstract class]]) {
        return [self.ext toJsonDictionary];
    }
    if ([self.ext isKindOfClass:[NSDictionary class]]) {
        return self.ext;
    }
    PBMLogError(@"Could not convert `%@`  (instance of %@) to PBMJsonDictionary -- please override `extAsJsonDictionary` in child class (%@).", [self.ext description], NSStringFromClass([self.ext class]), NSStringFromClass([self class]));
    return nil;
}

@end

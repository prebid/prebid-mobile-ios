//
//  OXMORTBAbstractResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstractResponse.h"
#import "OXMORTBAbstractResponse+Protected.h"

#import "OXMLog.h"

@implementation OXMORTBAbstractResponse

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary extParser:(id (^)(OXMJsonDictionary *))extParser {
    if (!(self = [super init])) {
        return nil;
    }
    OXMJsonDictionary * const rawExt = jsonDictionary[@"ext"];
    if (rawExt && extParser) {
        _ext = extParser(rawExt);
    }
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    [self populateJsonDictionary:ret];
    return ret;
}

- (void)populateJsonDictionary:(nonnull OXMMutableJsonDictionary *)jsonDictionary {
    OXMJsonDictionary * const extDic = self.extAsJsonDictionary;
    if (extDic) {
        jsonDictionary[@"ext"] = extDic;
    }
}

- (OXMJsonDictionary *)extAsJsonDictionary {
    if (!self.ext) {
        return nil;
    }
    if ([self.ext isKindOfClass:[OXMORTBAbstract class]]) {
        return [self.ext toJsonDictionary];
    }
    if ([self.ext isKindOfClass:[NSDictionary class]]) {
        return self.ext;
    }
    OXMLogError(@"Could not convert `%@`  (instance of %@) to OXMJsonDictionary -- please override `extAsJsonDictionary` in child class (%@).", [self.ext description], NSStringFromClass([self.ext class]), NSStringFromClass([self class]));
    return nil;
}

@end

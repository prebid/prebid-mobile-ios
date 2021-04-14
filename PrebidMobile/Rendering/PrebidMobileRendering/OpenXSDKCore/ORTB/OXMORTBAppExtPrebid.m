//
//  OXMORTBAppExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAppExtPrebid.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBAppExtPrebid

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    ret[@"source"] = self.source;
    ret[@"version"] = self.version;
    ret[@"data"] = self.data;
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _source = jsonDictionary[@"source"];
    _version = jsonDictionary[@"version"];
    _data = jsonDictionary[@"data"];
    return self;
}

@end

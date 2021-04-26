//
//  PBMORTBAppExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAppExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBAppExtPrebid

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    ret[@"source"] = self.source;
    ret[@"version"] = self.version;
    ret[@"data"] = self.data;
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _source = jsonDictionary[@"source"];
    _version = jsonDictionary[@"version"];
    _data = jsonDictionary[@"data"];
    return self;
}

@end

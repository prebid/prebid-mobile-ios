//
//  OXMORTBImpExtSkadn.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBImpExtSkadn.h"
#import "OXMORTBAbstract+Protected.h"

static NSString * const SKAdNetworkVersion = @"2.0";

@implementation OXMORTBImpExtSkadn

- (instancetype )init {
    if (self = [super init]) {
        _skadnetids = @[];
    }
    return self;
}

- (void)setSkadnetids:(NSArray<NSString *> *)scadnetids {
    _skadnetids = scadnetids ? [NSArray arrayWithArray:scadnetids] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [OXMMutableJsonDictionary new];
    
    if (self.sourceapp && self.skadnetids.count > 0) {
        ret[@"version"] = SKAdNetworkVersion;
        ret[@"sourceapp"] = self.sourceapp;
        ret[@"skadnetids"] = self.skadnetids;
    }
    
    [ret oxmRemoveEmptyVals];
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (self = [self init]) {
        _sourceapp = jsonDictionary[@"sourceapp"];
        _skadnetids = jsonDictionary[@"skadnetids"];
    }

    return self;
}
@end

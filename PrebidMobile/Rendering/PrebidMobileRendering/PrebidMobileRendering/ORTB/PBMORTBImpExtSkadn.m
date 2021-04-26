//
//  PBMORTBImpExtSkadn.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBImpExtSkadn.h"
#import "PBMORTBAbstract+Protected.h"

static NSString * const SKAdNetworkVersion = @"2.0";

@implementation PBMORTBImpExtSkadn

- (instancetype )init {
    if (self = [super init]) {
        _skadnetids = @[];
    }
    return self;
}

- (void)setSkadnetids:(NSArray<NSString *> *)scadnetids {
    _skadnetids = scadnetids ? [NSArray arrayWithArray:scadnetids] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [PBMMutableJsonDictionary new];
    
    if (self.sourceapp && self.skadnetids.count > 0) {
        ret[@"version"] = SKAdNetworkVersion;
        ret[@"sourceapp"] = self.sourceapp;
        ret[@"skadnetids"] = self.skadnetids;
    }
    
    [ret pbmRemoveEmptyVals];
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (self = [self init]) {
        _sourceapp = jsonDictionary[@"sourceapp"];
        _skadnetids = jsonDictionary[@"skadnetids"];
    }

    return self;
}
@end

//
//  PBMORTBFormat.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBFormat.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBFormat

- (instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    // nop -- all fields are nil
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"w"] = self.w;
    ret[@"h"] = self.h;
    ret[@"wratio"] = self.wratio;
    ret[@"hratio"] = self.hratio;
    ret[@"wmin"] = self.wmin;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if(!(self = [super init])) {
        return nil;
    }
    _w = jsonDictionary[@"w"];
    _h = jsonDictionary[@"h"];
    _wratio = jsonDictionary[@"wratio"];
    _hratio = jsonDictionary[@"hratio"];
    _wmin = jsonDictionary[@"wmin"];
    
    return self;
}

@end

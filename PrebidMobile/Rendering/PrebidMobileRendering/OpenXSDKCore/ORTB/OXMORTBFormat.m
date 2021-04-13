//
//  OXMORTBFormat.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBFormat.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBFormat

- (instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    // nop -- all fields are nil
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"w"] = self.w;
    ret[@"h"] = self.h;
    ret[@"wratio"] = self.wratio;
    ret[@"hratio"] = self.hratio;
    ret[@"wmin"] = self.wmin;
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
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

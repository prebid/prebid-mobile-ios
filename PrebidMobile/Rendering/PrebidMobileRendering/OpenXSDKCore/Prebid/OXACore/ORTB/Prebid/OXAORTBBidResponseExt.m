//
//  OXAORTBBidResponseExt.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBBidResponseExt.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXAORTBBidResponseExt

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _responsetimemillis = jsonDictionary[@"responsetimemillis"];
    _tmaxrequest = jsonDictionary[@"tmaxrequest"];
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"responsetimemillis"] = self.responsetimemillis;
    ret[@"tmaxrequest"] = self.tmaxrequest;
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end

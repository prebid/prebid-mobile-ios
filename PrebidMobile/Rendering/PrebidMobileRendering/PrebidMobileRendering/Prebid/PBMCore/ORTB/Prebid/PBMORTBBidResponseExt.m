//
//  PBMORTBBidResponseExt.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidResponseExt.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBBidResponseExt

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _responsetimemillis = jsonDictionary[@"responsetimemillis"];
    _tmaxrequest = jsonDictionary[@"tmaxrequest"];
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"responsetimemillis"] = self.responsetimemillis;
    ret[@"tmaxrequest"] = self.tmaxrequest;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end

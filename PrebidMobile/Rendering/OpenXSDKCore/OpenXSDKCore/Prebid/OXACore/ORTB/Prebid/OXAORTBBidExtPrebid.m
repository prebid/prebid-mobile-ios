//
//  OXAORTBBidExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBBidExtPrebid.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXAORTBBidExtPrebidCache.h"

@implementation OXAORTBBidExtPrebid

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    OXMJsonDictionary * const cacheDic = jsonDictionary[@"cache"];
    if (cacheDic) {
        _cache = [[OXAORTBBidExtPrebidCache alloc] initWithJsonDictionary:cacheDic];
    }
    
    _targeting = jsonDictionary[@"targeting"];
    _type = jsonDictionary[@"type"];
    
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"cache"] = [self.cache toJsonDictionary];
    ret[@"targeting"] = self.targeting;
    ret[@"type"] = self.type;
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end

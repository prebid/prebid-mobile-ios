//
//  PBMORTBBidExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBidExtPrebidCache.h"

@implementation PBMORTBBidExtPrebid

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    PBMJsonDictionary * const cacheDic = jsonDictionary[@"cache"];
    if (cacheDic) {
        _cache = [[PBMORTBBidExtPrebidCache alloc] initWithJsonDictionary:cacheDic];
    }
    
    _targeting = jsonDictionary[@"targeting"];
    _type = jsonDictionary[@"type"];
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"cache"] = [self.cache toJsonDictionary];
    ret[@"targeting"] = self.targeting;
    ret[@"type"] = self.type;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end

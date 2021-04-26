//
//  PBMORTBBidExtPrebidCache.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidExtPrebidCache.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBidExtPrebidCacheBids.h"

@implementation PBMORTBBidExtPrebidCache

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _url = jsonDictionary[@"url"];
    _key = jsonDictionary[@"key"];
    
    
    PBMJsonDictionary * const bidsDic = jsonDictionary[@"bids"];
    if (bidsDic) {
        _bids = [[PBMORTBBidExtPrebidCacheBids alloc] initWithJsonDictionary:bidsDic];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"key"] = self.key;
    ret[@"url"] = self.url;
    
    ret[@"bids"] = [self.bids toJsonDictionary];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end

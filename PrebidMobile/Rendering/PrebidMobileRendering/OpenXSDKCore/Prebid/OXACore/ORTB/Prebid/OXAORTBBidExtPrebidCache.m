//
//  OXAORTBBidExtPrebidCache.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBBidExtPrebidCache.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXAORTBBidExtPrebidCacheBids.h"

@implementation OXAORTBBidExtPrebidCache

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _url = jsonDictionary[@"url"];
    _key = jsonDictionary[@"key"];
    
    
    OXMJsonDictionary * const bidsDic = jsonDictionary[@"bids"];
    if (bidsDic) {
        _bids = [[OXAORTBBidExtPrebidCacheBids alloc] initWithJsonDictionary:bidsDic];
    }
    
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"key"] = self.key;
    ret[@"url"] = self.url;
    
    ret[@"bids"] = [self.bids toJsonDictionary];
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end

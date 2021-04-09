//
//  OXAORTBBidExtPrebidCacheBids.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBBidExtPrebidCacheBids.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXAORTBBidExtPrebidCacheBids

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _url = jsonDictionary[@"url"];
    _cacheId = jsonDictionary[@"cacheId"];
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"url"] = self.url;
    ret[@"cacheId"] = self.cacheId;
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end

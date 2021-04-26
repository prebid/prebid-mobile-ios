//
//  PBMORTBBidExtPrebidCacheBids.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidExtPrebidCacheBids.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBBidExtPrebidCacheBids

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _url = jsonDictionary[@"url"];
    _cacheId = jsonDictionary[@"cacheId"];
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"url"] = self.url;
    ret[@"cacheId"] = self.cacheId;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end

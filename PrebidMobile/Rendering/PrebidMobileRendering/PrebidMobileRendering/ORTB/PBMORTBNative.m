//
//  PBMORTBNative.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBNative.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBNative

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _ver = @"1.2";
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"request"] = self.request;
    ret[@"ver"] = self.ver;
    ret[@"api"] = self.api;
    ret[@"battr"] = self.battr;
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _request = jsonDictionary[@"request"];
    _ver = jsonDictionary[@"ver"];
    _api = jsonDictionary[@"api"];
    _battr = jsonDictionary[@"battr"];
    
    return self;
}

@end

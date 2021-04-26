//
//  PBMORTBBidRequestExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidRequestExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBBidRequestExtPrebid : PBMORTBAbstract

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    PBMMutableJsonDictionary * const cache = [PBMMutableJsonDictionary new];
    ret[@"cache"] = cache;
    
    cache[@"bids"] = [PBMMutableJsonDictionary new];
    cache[@"vastxml"] = [PBMMutableJsonDictionary new];
    
    PBMMutableJsonDictionary * const storedRequest = [PBMMutableJsonDictionary new];
    ret[@"storedrequest"] = storedRequest;
    storedRequest[@"id"] = self.storedRequestID;
    
    PBMMutableJsonDictionary * const targeting = [PBMMutableJsonDictionary new];
    ret[@"targeting"] = targeting;
    
    if (self.dataBidders != nil) {
        ret[@"data"] = @{
            @"bidders": self.dataBidders,
        };
    };
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _dataBidders = jsonDictionary[@"data"][@"bidders"];
    return self;
}

@end

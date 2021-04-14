//
//  OXMORTBBidRequestExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBBidRequestExtPrebid.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBBidRequestExtPrebid : OXMORTBAbstract

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    OXMMutableJsonDictionary * const cache = [OXMMutableJsonDictionary new];
    ret[@"cache"] = cache;
    
    cache[@"bids"] = [OXMMutableJsonDictionary new];
    cache[@"vastxml"] = [OXMMutableJsonDictionary new];
    
    OXMMutableJsonDictionary * const storedRequest = [OXMMutableJsonDictionary new];
    ret[@"storedrequest"] = storedRequest;
    storedRequest[@"id"] = self.storedRequestID;
    
    OXMMutableJsonDictionary * const targeting = [OXMMutableJsonDictionary new];
    ret[@"targeting"] = targeting;
    
    if (self.dataBidders != nil) {
        ret[@"data"] = @{
            @"bidders": self.dataBidders,
        };
    };
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _dataBidders = jsonDictionary[@"data"][@"bidders"];
    return self;
}

@end

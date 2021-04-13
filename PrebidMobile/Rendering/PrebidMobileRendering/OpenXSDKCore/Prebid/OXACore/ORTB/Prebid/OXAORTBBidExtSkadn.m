//
//  OXAORTBBidExtSkadn.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "OXMORTBAbstract+Protected.h"

#import "OXAORTBBidExtSkadn.h"

@implementation OXAORTBBidExtSkadn

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (self = [super init]) {
        _version = jsonDictionary[@"version"];
        _network = jsonDictionary[@"network"];
        _campaign = jsonDictionary[@"campaign"];
        _itunesitem = jsonDictionary[@"itunesitem"];
        _nonce = [[NSUUID alloc] initWithUUIDString:jsonDictionary[@"nonce"]];
        _sourceapp = jsonDictionary[@"sourceapp"];
        _timestamp = jsonDictionary[@"timestamp"];
        _signature = jsonDictionary[@"signature"];
        
    }
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"version"] = self.version;
    ret[@"network"] = self.network;
    ret[@"campaign"] = self.campaign;
    ret[@"itunesitem"] = self.itunesitem;
    ret[@"nonce"] = [self.nonce UUIDString];
    ret[@"sourceapp"] = self.sourceapp;
    ret[@"timestamp"] = self.timestamp;
    ret[@"signature"] = self.signature;
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end

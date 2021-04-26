//
//  PBMORTBBidExtSkadn.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBidExtSkadn.h"

@implementation PBMORTBBidExtSkadn

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
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

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"version"] = self.version;
    ret[@"network"] = self.network;
    ret[@"campaign"] = self.campaign;
    ret[@"itunesitem"] = self.itunesitem;
    ret[@"nonce"] = [self.nonce UUIDString];
    ret[@"sourceapp"] = self.sourceapp;
    ret[@"timestamp"] = self.timestamp;
    ret[@"signature"] = self.signature;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end

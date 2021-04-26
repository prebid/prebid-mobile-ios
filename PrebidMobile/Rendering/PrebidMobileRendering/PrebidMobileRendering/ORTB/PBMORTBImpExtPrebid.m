//
//  PBMORTBImpExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBImpExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBImpExtPrebid : PBMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    _isRewardedInventory = false;
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [PBMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    PBMMutableJsonDictionary * const storedRequest = [PBMMutableJsonDictionary new];
    storedRequest[@"id"] = self.storedRequestID;

    ret[@"storedrequest"] = storedRequest;
    
    if (self.isRewardedInventory) {
        ret[@"is_rewarded_inventory"] = @(1);
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _isRewardedInventory = jsonDictionary[@"is_rewarded_inventory"] != nil;
    
    return self;
}

@end

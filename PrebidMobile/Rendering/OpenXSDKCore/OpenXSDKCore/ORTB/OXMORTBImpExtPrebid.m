//
//  OXMORTBImpExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBImpExtPrebid.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBImpExtPrebid : OXMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    _isRewardedInventory = false;
    
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [OXMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    OXMMutableJsonDictionary * const storedRequest = [OXMMutableJsonDictionary new];
    storedRequest[@"id"] = self.storedRequestID;

    ret[@"storedrequest"] = storedRequest;
    
    if (self.isRewardedInventory) {
        ret[@"is_rewarded_inventory"] = @(1);
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _isRewardedInventory = jsonDictionary[@"is_rewarded_inventory"] != nil;
    
    return self;
}

@end

//
//  PBMORTBSourceExtOMID.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBSourceExtOMID.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBSourceExtOMID

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _omidpn = @"Prebid";
    _omidpv = [PBMFunctions omidVersion];
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    ret[@"omidpn"] = self.omidpn;
    ret[@"omidpv"] = self.omidpv;
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _omidpn = jsonDictionary[@"omidpn"];
    _omidpv = jsonDictionary[@"omidpv"];
    return self;
}

@end

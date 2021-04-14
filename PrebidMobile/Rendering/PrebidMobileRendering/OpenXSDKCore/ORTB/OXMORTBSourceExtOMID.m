//
//  OXMORTBSourceExtOMID.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBSourceExtOMID.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBSourceExtOMID

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _omidpn = @"Openx";
    _omidpv = [OXMFunctions omidVersion];
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    ret[@"omidpn"] = self.omidpn;
    ret[@"omidpv"] = self.omidpv;
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _omidpn = jsonDictionary[@"omidpn"];
    _omidpv = jsonDictionary[@"omidpv"];
    return self;
}

@end

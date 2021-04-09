//
//  OXAORTBDeviceExtAtts.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBDeviceExtAtts.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXAORTBDeviceExtAtts

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    if (self.ifv) {
        ret[@"ifv"] = self.ifv;
    }
    if (self.atts) {
        ret[@"atts"] = self.atts;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (self = [self init]) {
        _ifv = jsonDictionary[@"ifv"];
        _atts = jsonDictionary[@"atts"];
    }
    return self;
}

@end

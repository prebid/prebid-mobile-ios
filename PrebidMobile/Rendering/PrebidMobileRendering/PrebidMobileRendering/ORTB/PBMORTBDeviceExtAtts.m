//
//  PBMORTBDeviceExtAtts.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBDeviceExtAtts.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBDeviceExtAtts

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    if (self.ifv) {
        ret[@"ifv"] = self.ifv;
    }
    if (self.atts) {
        ret[@"atts"] = self.atts;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (self = [self init]) {
        _ifv = jsonDictionary[@"ifv"];
        _atts = jsonDictionary[@"atts"];
    }
    return self;
}

@end

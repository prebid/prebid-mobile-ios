//
//  PBMORTBDeviceExtPrebidInterstitial.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBDeviceExtPrebidInterstitial.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBDeviceExtPrebidInterstitial

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"minheightperc"] = self.minheightperc;
    ret[@"minwidthperc"] = self.minwidthperc;
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _minheightperc = jsonDictionary[@"minheightperc"];
    _minwidthperc = jsonDictionary[@"minwidthperc"];
    return self;
}

@end

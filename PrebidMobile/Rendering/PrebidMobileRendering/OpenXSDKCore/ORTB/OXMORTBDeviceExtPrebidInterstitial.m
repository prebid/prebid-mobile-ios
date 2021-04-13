//
//  OXMORTBDeviceExtPrebidInterstitial.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBDeviceExtPrebidInterstitial.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBDeviceExtPrebidInterstitial

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"minheightperc"] = self.minheightperc;
    ret[@"minwidthperc"] = self.minwidthperc;
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _minheightperc = jsonDictionary[@"minheightperc"];
    _minwidthperc = jsonDictionary[@"minwidthperc"];
    return self;
}

@end

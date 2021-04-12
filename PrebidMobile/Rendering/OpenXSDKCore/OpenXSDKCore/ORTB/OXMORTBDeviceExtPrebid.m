//
//  OXMORTBDeviceExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBDeviceExtPrebid.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBDeviceExtPrebidInterstitial.h"

@implementation OXMORTBDeviceExtPrebid

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _interstitial = [[OXMORTBDeviceExtPrebidInterstitial alloc] init];
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"interstitial"] = [[self.interstitial toJsonDictionary] nullIfEmpty];
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _interstitial = [[OXMORTBDeviceExtPrebidInterstitial alloc] initWithJsonDictionary:jsonDictionary[@"interstitial"]];
    return self;
}

@end

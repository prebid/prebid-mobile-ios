//
//  PBMORTBDeviceExtPrebid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBDeviceExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBDeviceExtPrebidInterstitial.h"

@implementation PBMORTBDeviceExtPrebid

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _interstitial = [[PBMORTBDeviceExtPrebidInterstitial alloc] init];
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"interstitial"] = [[self.interstitial toJsonDictionary] nullIfEmpty];
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _interstitial = [[PBMORTBDeviceExtPrebidInterstitial alloc] initWithJsonDictionary:jsonDictionary[@"interstitial"]];
    return self;
}

@end

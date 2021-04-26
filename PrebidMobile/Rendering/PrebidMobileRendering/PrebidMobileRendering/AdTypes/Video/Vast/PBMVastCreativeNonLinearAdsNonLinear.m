//
//  PBMVastCreativeNonLinearAdsNonLinear.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeNonLinearAdsNonLinear.h"

@implementation PBMVastCreativeNonLinearAdsNonLinear

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clickTrackingURIs = [NSMutableArray array];
        self.vastTrackingEvents = [PBMVastTrackingEvents new];
    }
    
    return self;
}

@end

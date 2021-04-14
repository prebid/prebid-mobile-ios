//
//  OXMVastCreativeNonLinearAdsNonLinear.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeNonLinearAdsNonLinear.h"

@implementation OXMVastCreativeNonLinearAdsNonLinear

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clickTrackingURIs = [NSMutableArray array];
        self.vastTrackingEvents = [OXMVastTrackingEvents new];
    }
    
    return self;
}

@end

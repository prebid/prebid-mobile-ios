//
//  OXMVastCreativeNonLinearAds.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeNonLinearAds.h"

@implementation OXMVastCreativeNonLinearAds

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.nonLinears = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public

-(void)copyTracking:(OXMVastCreativeNonLinearAds *)fromNonLinearAds {
    if (!fromNonLinearAds) {
        return;
    }
    
    for (OXMVastCreativeNonLinearAdsNonLinear *fromNonLinear in fromNonLinearAds.nonLinears) {
        for (OXMVastCreativeNonLinearAdsNonLinear *toNonLinear in self.nonLinears) {
            [toNonLinear.clickTrackingURIs addObjectsFromArray:fromNonLinear.clickTrackingURIs];
            [toNonLinear.vastTrackingEvents addTrackingEvents:fromNonLinear.vastTrackingEvents];
        }
    }
}

@end

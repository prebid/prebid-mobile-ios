//
//  PBMVastCreativeNonLinearAds.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeNonLinearAds.h"

@implementation PBMVastCreativeNonLinearAds

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

-(void)copyTracking:(PBMVastCreativeNonLinearAds *)fromNonLinearAds {
    if (!fromNonLinearAds) {
        return;
    }
    
    for (PBMVastCreativeNonLinearAdsNonLinear *fromNonLinear in fromNonLinearAds.nonLinears) {
        for (PBMVastCreativeNonLinearAdsNonLinear *toNonLinear in self.nonLinears) {
            [toNonLinear.clickTrackingURIs addObjectsFromArray:fromNonLinear.clickTrackingURIs];
            [toNonLinear.vastTrackingEvents addTrackingEvents:fromNonLinear.vastTrackingEvents];
        }
    }
}

@end

//
//  PBMVastCreativeCompanionAdsCompanion.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeCompanionAdsCompanion.h"

@implementation PBMVastCreativeCompanionAdsCompanion

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clickTrackingURIs = [NSMutableArray array];
        self.trackingEvents = [PBMVastTrackingEvents new];
    }
    return self;
}

@end

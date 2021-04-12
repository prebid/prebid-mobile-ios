//
//  OXMVastCreativeCompanionAdsCompanion.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeCompanionAdsCompanion.h"

@implementation OXMVastCreativeCompanionAdsCompanion

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clickTrackingURIs = [NSMutableArray array];
        self.trackingEvents = [OXMVastTrackingEvents new];
    }
    return self;
}

@end

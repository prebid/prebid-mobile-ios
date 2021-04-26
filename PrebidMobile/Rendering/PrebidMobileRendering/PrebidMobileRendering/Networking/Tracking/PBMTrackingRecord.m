//
//  PBMTrackingRecord.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTrackingRecord.h"
#import "PBMMacros.h"

@implementation PBMTrackingRecord

#pragma mark - Initialization

-(instancetype)initWithTrackingType:(NSString *)trackingType trackingURL:(NSString *)trackingURL {
    self = [super init];
    if (self) {
        PBMAssert(trackingType && trackingURL);
        
        self.trackingURL = trackingURL ?: @"";
        self.trackingType = trackingType ?: @"";
    }
    return self;
}

@end

//
//  OXMTrackingRecord.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTrackingRecord.h"
#import "OXMMacros.h"

@implementation OXMTrackingRecord

#pragma mark - Initialization

-(instancetype)initWithTrackingType:(NSString *)trackingType trackingURL:(NSString *)trackingURL {
    self = [super init];
    if (self) {
        OXMAssert(trackingType && trackingURL);
        
        self.trackingURL = trackingURL ?: @"";
        self.trackingType = trackingType ?: @"";
    }
    return self;
}

@end

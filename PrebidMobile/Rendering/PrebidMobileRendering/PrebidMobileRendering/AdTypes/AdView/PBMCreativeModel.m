//
//  PBMCreativeModel.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMCreativeModel.h"
#import "PBMMacros.h"
#import "PBMAdModelEventTracker.h"

@implementation PBMCreativeModel

#pragma mark - Initialization

-(instancetype)initWithAdConfiguration:(PBMAdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        PBMAssert(adConfiguration);
        
        self.trackingURLs = [NSDictionary new];
        self.adConfiguration = adConfiguration;
    }
    
    return self;
}

- (void)trackEvent:(PBMTrackingEvent)event {
    [self.eventTracker trackEvent:event];
}


@end

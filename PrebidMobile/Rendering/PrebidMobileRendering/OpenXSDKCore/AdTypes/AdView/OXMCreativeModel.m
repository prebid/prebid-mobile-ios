//
//  OXMCreativeModel.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMCreativeModel.h"
#import "OXMMacros.h"
#import "OXMAdModelEventTracker.h"

@implementation OXMCreativeModel

#pragma mark - Initialization

-(instancetype)initWithAdConfiguration:(OXMAdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        OXMAssert(adConfiguration);
        
        self.trackingURLs = [NSDictionary new];
        self.adConfiguration = adConfiguration;
    }
    
    return self;
}

- (void)trackEvent:(OXMTrackingEvent)event {
    [self.eventTracker trackEvent:event];
}


@end

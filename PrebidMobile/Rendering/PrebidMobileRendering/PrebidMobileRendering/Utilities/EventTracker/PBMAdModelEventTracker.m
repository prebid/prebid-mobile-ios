//
//  PBMEventTracker.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdModelEventTracker.h"
#import "PBMCreativeModel.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMMacros.h"

@interface PBMAdModelEventTracker()

@property (nonatomic, weak) PBMCreativeModel *creativeModel;
@property (nonatomic, strong) id<PBMServerConnectionProtocol> serverConnection;

@end

@implementation PBMAdModelEventTracker

#pragma mark - Initialization

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                     serverConnection:(id<PBMServerConnectionProtocol>)serverConnection {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
    }
    
    return self;
}

#pragma mark - PBMEventTrackerProtocol

// Tracking Firing
- (void)trackEvent:(PBMTrackingEvent)event {
    NSString *eventName = [PBMTrackingEventDescription getDescription:event];
    PBMAssert(eventName);
    if (!eventName) {
        return;
    }
    
    NSArray *urls = self.creativeModel.trackingURLs[eventName];
    if (!urls) {
        PBMLogInfo(@"No tracking URL(s) for event %@", eventName);
        return;
    }
    
    for (NSString *url in urls) {
        [self.serverConnection fireAndForget:url];
    }
}

- (void)trackVideoAdLoaded:(PBMVideoVerificationParameters *)parameters {
}

- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    [self trackEvent:PBMTrackingEventStart];
}

- (void)trackVolumeChanged:(CGFloat)volume deviceVolume:(CGFloat)deviceVolume{
}

@end

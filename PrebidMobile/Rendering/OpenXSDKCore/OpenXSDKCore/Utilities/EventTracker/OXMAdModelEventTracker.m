//
//  OXMEventTracker.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdModelEventTracker.h"
#import "OXMCreativeModel.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMMacros.h"

@interface OXMAdModelEventTracker()

@property (nonatomic, weak) OXMCreativeModel *creativeModel;
@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;

@end

@implementation OXMAdModelEventTracker

#pragma mark - Initialization

- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                     serverConnection:(id<OXMServerConnectionProtocol>)serverConnection {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
    }
    
    return self;
}

#pragma mark - OXMEventTrackerProtocol

// Tracking Firing
- (void)trackEvent:(OXMTrackingEvent)event {
    NSString *eventName = [OXMTrackingEventDescription getDescription:event];
    OXMAssert(eventName);
    if (!eventName) {
        return;
    }
    
    NSArray *urls = self.creativeModel.trackingURLs[eventName];
    if (!urls) {
        OXMLogInfo(@"No tracking URL(s) for event %@", eventName);
        return;
    }
    
    for (NSString *url in urls) {
        [self.serverConnection fireAndForget:url];
    }
}

- (void)trackVideoAdLoaded:(OXMVideoVerificationParameters *)parameters {
}

- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    [self trackEvent:OXMTrackingEventStart];
}

- (void)trackVolumeChanged:(CGFloat)volume deviceVolume:(CGFloat)deviceVolume{
}

@end

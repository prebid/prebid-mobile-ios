//
//  OXMEventManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMEventManager.h"
#import "OXMLog.h"

@interface OXMEventManager()

@property (nonatomic, strong) NSMutableArray<id<OXMEventTrackerProtocol>> *trackers;

@end

@implementation OXMEventManager

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.trackers = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - OXMEventTrackerProtocol
- (void)trackEvent:(OXMTrackingEvent)event {
    for (id<OXMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackEvent:event];
    }
}

- (void)trackVideoAdLoaded:(OXMVideoVerificationParameters *)parameters {
    for (id<OXMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackVideoAdLoaded:parameters];
    }
}
- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    for (id<OXMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackStartVideoWithDuration:duration volume:volume];
    }
}

- (void)trackVolumeChanged:(CGFloat)playerVolume deviceVolume:(CGFloat)deviceVolume {
    for (id<OXMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackVolumeChanged:playerVolume deviceVolume:deviceVolume];
    }
}

#pragma mark - Public Methods

- (void)registerTracker:(id<OXMEventTrackerProtocol>)tracker {
    if (!tracker || [self.trackers indexOfObject:tracker] != NSNotFound) {
        return;
    }
    
    [self.trackers addObject:tracker];
}

- (void)unregisterTracker:(id<OXMEventTrackerProtocol>)tracker {
    if (!tracker) {
        OXMLogError(@"Can't unregister empty event tracker");
        return;
    }
    
    [self.trackers removeObject:tracker];
}

@end

//
//  PBMEventManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMEventManager.h"
#import "PBMLog.h"

@interface PBMEventManager()

@property (nonatomic, strong) NSMutableArray<id<PBMEventTrackerProtocol>> *trackers;

@end

@implementation PBMEventManager

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.trackers = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - PBMEventTrackerProtocol
- (void)trackEvent:(PBMTrackingEvent)event {
    for (id<PBMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackEvent:event];
    }
}

- (void)trackVideoAdLoaded:(PBMVideoVerificationParameters *)parameters {
    for (id<PBMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackVideoAdLoaded:parameters];
    }
}
- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    for (id<PBMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackStartVideoWithDuration:duration volume:volume];
    }
}

- (void)trackVolumeChanged:(CGFloat)playerVolume deviceVolume:(CGFloat)deviceVolume {
    for (id<PBMEventTrackerProtocol> tracker in self.trackers) {
        [tracker trackVolumeChanged:playerVolume deviceVolume:deviceVolume];
    }
}

#pragma mark - Public Methods

- (void)registerTracker:(id<PBMEventTrackerProtocol>)tracker {
    if (!tracker || [self.trackers indexOfObject:tracker] != NSNotFound) {
        return;
    }
    
    [self.trackers addObject:tracker];
}

- (void)unregisterTracker:(id<PBMEventTrackerProtocol>)tracker {
    if (!tracker) {
        PBMLogError(@"Can't unregister empty event tracker");
        return;
    }
    
    [self.trackers removeObject:tracker];
}

@end

//
//  OXAViewabilityEventDetector.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityEventDetector.h"

#import "OXAViewabilityEventStatus.h"


@interface OXAViewabilityEventDetector()

@property (nonatomic, strong, nonnull, readonly) NSArray<OXAViewabilityEventStatus *> *trackedEvents;
@property (nonatomic, copy, nullable, readonly) OXMVoidBlock onLastEventDetected;

@property (nonatomic, assign) BOOL lastEventReported;

@end




@implementation OXAViewabilityEventDetector

- (instancetype)initWithViewabilityEvents:(NSArray<OXAViewabilityEvent *> *)viewabilityEvents
                      onLastEventDetected:(nullable OXMVoidBlock)onLastEventDetected
{
    if (!(self = [super init])) {
        return nil;
    }
    NSMutableArray<OXAViewabilityEventStatus *> * const trackedEvents = [[NSMutableArray alloc]
                                                                         initWithCapacity:viewabilityEvents.count];
    for (OXAViewabilityEvent *nextEvent in viewabilityEvents) {
        [trackedEvents addObject:[[OXAViewabilityEventStatus alloc] initWithViewabilityEvent:nextEvent]];
    }
    _trackedEvents = trackedEvents;
    _onLastEventDetected = [onLastEventDetected copy];
    return self;
}

- (void)onExposureMeasured:(float)exposureFactor passedSinceLastMeasurement:(NSTimeInterval)deltaTime {
    if (self.lastEventReported) {
        return;
    }
    NSInteger eventsRemaining = 0;
    for (OXAViewabilityEventStatus *nextTrackedEvent in self.trackedEvents) {
        if (nextTrackedEvent.detected) {
            continue;
        }
        if (!nextTrackedEvent.viewabilityEvent.exposureSatisfactionCheck(exposureFactor)) {
            nextTrackedEvent.satisfactionProgress = 0;
            nextTrackedEvent.isProgressing = NO;
            eventsRemaining += 1;
            continue;
        }
        NSTimeInterval const lastSatisfactionProgress = nextTrackedEvent.satisfactionProgress;
        BOOL const wasProgressing = nextTrackedEvent.isProgressing;
        
        if (wasProgressing) {
            nextTrackedEvent.satisfactionProgress = lastSatisfactionProgress + deltaTime;
        } else {
            nextTrackedEvent.isProgressing = YES;
        }
        
        if (nextTrackedEvent.viewabilityEvent.durationSatisfactionCheck(nextTrackedEvent.satisfactionProgress)) {
            nextTrackedEvent.detected = YES;
            nextTrackedEvent.isProgressing = NO;
            nextTrackedEvent.viewabilityEvent.onEventDetected();
        } else {
            eventsRemaining += 1;
        }
    }
    if (eventsRemaining == 0) {
        self.lastEventReported = YES;
        self.onLastEventDetected();
    }
}

@end

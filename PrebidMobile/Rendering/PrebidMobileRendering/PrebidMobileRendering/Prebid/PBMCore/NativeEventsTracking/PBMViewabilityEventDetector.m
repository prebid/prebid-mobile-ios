/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMViewabilityEventDetector.h"

#import "PBMViewabilityEventStatus.h"


@interface PBMViewabilityEventDetector()

@property (nonatomic, strong, nonnull, readonly) NSArray<PBMViewabilityEventStatus *> *trackedEvents;
@property (nonatomic, copy, nullable, readonly) PBMVoidBlock onLastEventDetected;

@property (nonatomic, assign) BOOL lastEventReported;

@end




@implementation PBMViewabilityEventDetector

- (instancetype)initWithViewabilityEvents:(NSArray<PBMViewabilityEvent *> *)viewabilityEvents
                      onLastEventDetected:(nullable PBMVoidBlock)onLastEventDetected
{
    if (!(self = [super init])) {
        return nil;
    }
    NSMutableArray<PBMViewabilityEventStatus *> * const trackedEvents = [[NSMutableArray alloc]
                                                                         initWithCapacity:viewabilityEvents.count];
    for (PBMViewabilityEvent *nextEvent in viewabilityEvents) {
        [trackedEvents addObject:[[PBMViewabilityEventStatus alloc] initWithViewabilityEvent:nextEvent]];
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
    for (PBMViewabilityEventStatus *nextTrackedEvent in self.trackedEvents) {
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

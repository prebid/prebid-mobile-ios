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

#import "PBMEventManager.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

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
        LogError(@"Can't unregister empty event tracker");
        return;
    }
    
    [self.trackers removeObject:tracker];
}

@end

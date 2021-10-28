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

#import "PBMViewabilityPlaybackBinder.h"

#import "PBMPollingTimer.h"
#import "PBMMacros.h"


@interface PBMViewabilityPlaybackBinder ()

@property (nonatomic, copy, nonnull, readonly) PBMViewExposureProvider exposureProvider;
@property (nonatomic, weak, nullable, readonly) id<PBMPlayable> playable;

@property (nonatomic, strong, nullable) PBMPollingTimer *pollingTimer;

@property (nonatomic, strong, nonnull) PBMViewExposure *lastExposure;

@end



@implementation PBMViewabilityPlaybackBinder

- (instancetype)initWithExposureProvider:(PBMViewExposureProvider)exposureProvider
                         pollingInterval:(NSTimeInterval)pollingInterval
                   scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                                playable:(id<PBMPlayable>)playable
{
    if (!(self = [super init])) {
        return nil;
    }
    _exposureProvider = exposureProvider;
    _lastExposure = [PBMViewExposure zeroExposure];
    _playable = playable;
    @weakify(self);
    _pollingTimer = [[PBMPollingTimer alloc] initWithPollingInterval:pollingInterval
                                               scheduledTimerFactory:scheduledTimerFactory
                                                        pollingBlock:^(NSTimeInterval timeSinceLastPolling)
    {
        @strongify(self);
        [self checkPlaybackTriggers];
    }];
    [_pollingTimer pollNow];
    return self;
}

- (void)checkPlaybackTriggers {
    if (self.playable == nil) {
        self.pollingTimer = nil;
        return;
    }
    PBMViewExposure * const newExposure = self.exposureProvider();
    BOOL const hadVisiblePixel = (self.lastExposure.exposureFactor > 0);
    BOOL const hasVisiblePixel = (newExposure.exposureFactor > 0);
    if (hasVisiblePixel && !hadVisiblePixel) { // Became visible
        if ([self.playable canPlay]) {
            [self.playable play];
        }
        if ([self.playable canAutoResume]) {
            [self.playable resume];
        }
    } else if (hadVisiblePixel && !hasVisiblePixel) { // Became invisible
        [self.playable autoPause];
    }
    self.lastExposure = newExposure;
}

@end

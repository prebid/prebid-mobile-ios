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

#import "PBMPollingTimer.h"

#import "PBMWeakTimerTargetBox.h"


@interface PBMPollingTimer ()

@property (nonatomic, copy, nonnull, readonly) PBMScheduledTimerFactory scheduledTimerFactory;
@property (nonatomic, assign, readonly) NSTimeInterval pollingInterval;
@property (nonatomic, copy, nonnull, readonly) PBMPollingBlock pollingBlock;

@property (nonatomic, strong, nullable) id<PBMTimerInterface> timer;
@property (nonatomic, strong, nullable) NSDate *lastCheckTimestamp;

@end



@implementation PBMPollingTimer

- (void)dealloc {
    [self.timer invalidate];
}

- (instancetype)initWithPollingInterval:(NSTimeInterval)pollingInterval
                  scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                           pollingBlock:(PBMPollingBlock)pollingBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _scheduledTimerFactory = [PBMWeakTimerTargetBox
                              scheduledTimerFactoryWithWeakifiedTarget:[scheduledTimerFactory copy]];
    _pollingInterval = pollingInterval;
    _pollingBlock = [pollingBlock copy];
    
    [self setupTimer];
    
    return self;
}

- (void)pollNow {
    [self.timer invalidate];
    [self setupTimer];
    [self sendCurrentViewability];
}

// MARK: - Private Helpers

- (void)setupTimer {
    self.timer = self.scheduledTimerFactory(self.pollingInterval, self, @selector(sendCurrentViewability), nil, YES);
}

- (void)sendCurrentViewability {
    NSDate * const now = [NSDate date];
    NSDate * const lastTime = self.lastCheckTimestamp;
    NSTimeInterval const passedSinceLastCheck = (lastTime == nil) ? 0 : [now timeIntervalSinceDate:lastTime];
    self.lastCheckTimestamp = now;
    self.pollingBlock(passedSinceLastCheck);
}

@end

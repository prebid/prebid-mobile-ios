//
//  PBMPollingTimer.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

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

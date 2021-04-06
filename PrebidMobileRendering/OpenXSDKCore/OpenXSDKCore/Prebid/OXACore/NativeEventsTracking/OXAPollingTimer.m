//
//  OXAPollingTimer.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAPollingTimer.h"

#import "OXAWeakTimerTargetBox.h"


@interface OXAPollingTimer ()

@property (nonatomic, copy, nonnull, readonly) OXAScheduledTimerFactory scheduledTimerFactory;
@property (nonatomic, assign, readonly) NSTimeInterval pollingInterval;
@property (nonatomic, copy, nonnull, readonly) OXAPollingBlock pollingBlock;

@property (nonatomic, strong, nullable) id<OXATimerInterface> timer;
@property (nonatomic, strong, nullable) NSDate *lastCheckTimestamp;

@end



@implementation OXAPollingTimer

- (void)dealloc {
    [self.timer invalidate];
}

- (instancetype)initWithPollingInterval:(NSTimeInterval)pollingInterval
                  scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                           pollingBlock:(OXAPollingBlock)pollingBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _scheduledTimerFactory = [OXAWeakTimerTargetBox
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

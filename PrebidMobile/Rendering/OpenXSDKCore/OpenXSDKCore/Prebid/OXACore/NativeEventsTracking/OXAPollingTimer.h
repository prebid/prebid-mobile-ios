//
//  OXAPollingTimer.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAPollingBlock.h"
#import "OXAScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAPollingTimer : NSObject

- (instancetype)initWithPollingInterval:(NSTimeInterval)pollingInterval
                  scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                           pollingBlock:(OXAPollingBlock)pollingBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Immediately calls 'pollingBlock' and resets time till next polling
- (void)pollNow;

@end

NS_ASSUME_NONNULL_END

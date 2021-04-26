//
//  PBMPollingTimer.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMPollingBlock.h"
#import "PBMScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMPollingTimer : NSObject

- (instancetype)initWithPollingInterval:(NSTimeInterval)pollingInterval
                  scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                           pollingBlock:(PBMPollingBlock)pollingBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Immediately calls 'pollingBlock' and resets time till next polling
- (void)pollNow;

@end

NS_ASSUME_NONNULL_END

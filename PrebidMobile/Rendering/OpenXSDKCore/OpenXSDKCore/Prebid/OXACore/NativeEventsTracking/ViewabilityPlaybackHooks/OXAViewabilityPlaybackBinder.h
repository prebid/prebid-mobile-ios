//
//  OXAViewabilityPlaybackBinder.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAPlayable.h"
#import "OXAScheduledTimerFactory.h"
#import "OXAViewExposureProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAViewabilityPlaybackBinder : NSObject

- (instancetype)initWithExposureProvider:(OXAViewExposureProvider)exposureProvider
                         pollingInterval:(NSTimeInterval)pollingInterval
                   scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                                playable:(id<OXAPlayable>)playable NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

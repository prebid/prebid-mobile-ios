//
//  PBMViewabilityPlaybackBinder.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMPlayable.h"
#import "PBMScheduledTimerFactory.h"
#import "PBMViewExposureProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMViewabilityPlaybackBinder : NSObject

- (instancetype)initWithExposureProvider:(PBMViewExposureProvider)exposureProvider
                         pollingInterval:(NSTimeInterval)pollingInterval
                   scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                                playable:(id<PBMPlayable>)playable NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

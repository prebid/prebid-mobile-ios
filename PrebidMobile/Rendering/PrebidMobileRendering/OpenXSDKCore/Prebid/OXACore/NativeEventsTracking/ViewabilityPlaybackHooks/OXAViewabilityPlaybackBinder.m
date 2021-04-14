//
//  OXAViewabilityPlaybackBinder.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityPlaybackBinder.h"

#import "OXAPollingTimer.h"
#import "OXMMacros.h"


@interface OXAViewabilityPlaybackBinder ()

@property (nonatomic, copy, nonnull, readonly) OXAViewExposureProvider exposureProvider;
@property (nonatomic, weak, nullable, readonly) id<OXAPlayable> playable;

@property (nonatomic, strong, nullable) OXAPollingTimer *pollingTimer;

@property (nonatomic, strong, nonnull) OXMViewExposure *lastExposure;

@end



@implementation OXAViewabilityPlaybackBinder

- (instancetype)initWithExposureProvider:(OXAViewExposureProvider)exposureProvider
                         pollingInterval:(NSTimeInterval)pollingInterval
                   scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                                playable:(id<OXAPlayable>)playable
{
    if (!(self = [super init])) {
        return nil;
    }
    _exposureProvider = exposureProvider;
    _lastExposure = [OXMViewExposure zeroExposure];
    _playable = playable;
    @weakify(self);
    _pollingTimer = [[OXAPollingTimer alloc] initWithPollingInterval:pollingInterval
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
    OXMViewExposure * const newExposure = self.exposureProvider();
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

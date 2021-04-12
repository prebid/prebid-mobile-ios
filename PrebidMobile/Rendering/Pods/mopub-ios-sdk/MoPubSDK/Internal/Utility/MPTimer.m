//
//  MPTimer.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/message.h> // for `objc_msgSend`
#import "MPTimer.h"
#import "MPLogging.h"

@interface MPTimer ()

@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isRepeatingTimer;
@property (nonatomic, assign) BOOL isCountdownActive;

// Time remaining after `pause` has been called. Values <= 0 indicate this field
// is not valid at this time.
@property (nonatomic, assign) NSTimeInterval remainingTime;

@property (nonatomic, copy) void(^timerCallbackBlock)(MPTimer *timer);

// Access to `NSTimer` is not thread-safe by default, so we will gate access
// to it using GCD to allow concurrent reads, but synchronous writes.
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation MPTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds
                             repeats:(BOOL)repeats
                         runLoopMode:(NSString *)runLoopMode
                               block:(void(^)(MPTimer *timer))block {
    if (self = [super init]) {
        // Dispatch queue used to gate multithreaded access.
        _syncQueue = dispatch_queue_create("com.mopub.mopub-ios-sdk.mptimer.queue", DISPATCH_QUEUE_CONCURRENT);

        // Initialize internal state
        _isCountdownActive = NO;
        _isRepeatingTimer = repeats;
        _timerCallbackBlock = block;
        _timeInterval = seconds;
        _remainingTime = 0;

        // Initialize the internal `NSTimer`, but set its fire date in the far future.
        // `scheduleNow` will handle the firing of the timer.
        __typeof__(self) __weak weakSelf = self;
        _timer = [NSTimer timerWithTimeInterval:seconds repeats:repeats block:^(NSTimer * _Nonnull nsTimer) {
            __typeof__(self) strongSelf = weakSelf;

            // Timer has fired, so there is no remaining time left.
            strongSelf.remainingTime = 0;

            // This is the last block to fire.
            if (!strongSelf.isRepeatingTimer) {
                strongSelf.isCountdownActive = NO;
                [nsTimer invalidate];
            }

            // Extra validation for the timer callback block.
            if (strongSelf.timerCallbackBlock == nil) {
                MPLogDebug(@"%s `timerCallbackBlock` is unexpectedly nil. Return early to avoid crash.", __FUNCTION__);
                return;
            }

            // Forward the callback along
            strongSelf.timerCallbackBlock(self);
        }];
        [_timer setFireDate:NSDate.distantFuture];

        // Runloop scheduling must be performed on the main thread. To prevent
        // a potential deadlock, scheduling to the main thread will be asynchronous
        // on the next main thread run loop.
        void (^mainThreadOperation)(void) = ^void(void) {
            // `nil` check should be performed here in case of the situation where
            // the timer is created on a background thread, the runloop scheduling block
            // is then scheduled to run on main thread, but before the block can
            // process, a timer invalidation event occurs which invalidates the underlying
            // `NSTimer` and set it to `nil`.
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf.timer != nil) {
                [NSRunLoop.mainRunLoop addTimer:strongSelf.timer forMode:runLoopMode];
            }
        };

        if ([NSThread isMainThread]) {
            mainThreadOperation();
        } else {
            dispatch_async(dispatch_get_main_queue(), mainThreadOperation);
        }
    }

    return self;
}

+ (MPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                           repeats:(BOOL)repeats
                       runLoopMode:(NSString *)runLoopMode
                             block:(void(^)(MPTimer *timer))block {
    return [[MPTimer alloc] initWithTimeInterval:seconds repeats:repeats runLoopMode:runLoopMode block:block];
}

+ (MPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                           repeats:(BOOL)repeats
                             block:(void(^)(MPTimer *timer))block {
    return [[MPTimer alloc] initWithTimeInterval:seconds repeats:repeats runLoopMode:NSDefaultRunLoopMode block:block];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)isValid {
    __block BOOL isValidValue = NO;
    dispatch_sync(self.syncQueue, ^{
        isValidValue = self.timer.isValid;
    });

    return isValidValue;
}

- (void)invalidate {
    dispatch_barrier_sync(self.syncQueue, ^{
        [self.timer invalidate];
        self.timer = nil;
        self.isCountdownActive = NO;
    });
}

- (void)scheduleNow {
    /*
     Note: `MPLog` statements are commented out because during SDK init, the chain of calls
     `MPConsentManager.sharedManager` -> `newNextUpdateTimer` -> `MPTimer.scheduleNow` ->
     `MPLogDebug` -> `MPIdentityProvider.identifier` -> `MPConsentManager.sharedManager` will cause
     a crash with EXC_BAD_INSTRUCTION: the same `dispatch_once` is called twice for
     `MPConsentManager.sharedManager` in the same call stack. Uncomment the logs after
     `MPIdentityProvider` is refactored.
     */
    dispatch_barrier_sync(self.syncQueue, ^{
        if (!self.timer.isValid) {
            return;
        }

        if (self.isCountdownActive) {
            return;
        }

        // Use the remaining time if this timer was paused; otherwise
        // use the caller-specified time interval.
        NSTimeInterval interval = (self.remainingTime <= 0 ? self.timeInterval : self.remainingTime);

        NSDate *newFireDate = [NSDate dateWithTimeInterval:interval sinceDate:[NSDate date]];
        [self.timer setFireDate:newFireDate];
        self.isCountdownActive = YES;
    });
}

- (void)pause {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (!self.isCountdownActive) {
            MPLogDebug(@"No-op: tried to pause an MPTimer (%p) that was already paused.", self);
            return;
        }

        if (![self.timer isValid]) {
            MPLogDebug(@"Cannot pause invalidated MPTimer (%p).", self);
            return;
        }

        // `fireDate` is the date which the timer will fire. If the timer is no longer valid, `fireDate`
        // is the last date at which the timer fired.
        NSTimeInterval secondsLeft = [[self.timer fireDate] timeIntervalSinceDate:[NSDate date]];
        if (secondsLeft <= 0) {
            MPLogInfo(@"An MPTimer was somehow paused after it was supposed to fire.");
        } else {
            self.remainingTime = secondsLeft;
            MPLogDebug(@"Paused MPTimer (%p) %.1f seconds left before firing.", self, secondsLeft);
        }

        // Pause the timer by setting its fire date far into the future.
        [self.timer setFireDate:[NSDate distantFuture]];
        self.isCountdownActive = NO;
    });
}

- (void)resume {
    [self scheduleNow];
    MPLogDebug(@"Resuming MPTimer (%p) %.1f seconds left before firing.", self, self.remainingTime);
}

@end

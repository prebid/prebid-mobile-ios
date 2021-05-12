//
//  MPCountdownTimerView.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPCountdownTimerView.h"
#import "MPLogging.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

static NSTimeInterval const kCountdownTimerInterval = 0.05; // internal timer firing frequency in seconds
static CGFloat const kTimerStartAngle = -M_PI * 0.5; // 12 o'clock position
static CGFloat const kOneCycle = M_PI * 2;
static CGFloat const kRingWidth = 3; // The width of the ring is not accounted to the view size.
static CGFloat const kRingRadius = 16;
static CGFloat const kRingPadding = 9;
static NSString * const kAnimationKey = @"Timer";

/*
 (kRingRadius + kRingPadding) * 2 = (16 + 9) * 2 = 50, which is the same dimension as MRAID close event
 region. See MRAID spec https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf, page 31.
 */
@interface MPCountdownTimerView()

@property (nonatomic, copy) void(^completionBlock)(BOOL);
@property (nonatomic, assign) NSTimeInterval remainingSeconds;
@property (nonatomic, strong) MPResumableTimer * timer; // timer instantiation is deferred to `start`
@property (nonatomic, strong) CAShapeLayer * backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer * animatingRingLayer;
@property (nonatomic, strong) UILabel * countdownLabel;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation MPCountdownTimerView

#pragma mark - Life Cycle

- (instancetype)initWithDuration:(NSTimeInterval)seconds timerCompletion:(void(^)(BOOL hasElapsed))completion {
    if (self = [super initWithFrame:CGRectZero]) {
        if (seconds <= 0) {
            MPLogDebug(@"Attempted to initialize MPCountdownTimerView with a non-positive duration. No timer will be created.");
            return nil;
        }

        _completionBlock = completion;
        _remainingSeconds = seconds;
        _timer = nil; // timer instantiation is deferred to `start`
        _notificationCenter = [NSNotificationCenter defaultCenter];

        CGPoint ringCenter = CGPointMake([MPCountdownTimerView intrinsicContentDimension] / 2,
                                         [MPCountdownTimerView intrinsicContentDimension] / 2);

        // the actual animation is the reverse of this path
        UIBezierPath * circularPath = [UIBezierPath bezierPathWithArcCenter:ringCenter
                                                                     radius:kRingRadius
                                                                 startAngle:kTimerStartAngle + kOneCycle
                                                                   endAngle:kTimerStartAngle
                                                                  clockwise:false];
        _backgroundRingLayer = ({
            CAShapeLayer * layer = [CAShapeLayer new];
            layer.fillColor = UIColor.blackColor.CGColor;
            layer.lineWidth = kRingWidth;
            layer.path = [circularPath CGPath];
            layer.strokeColor = [UIColor.whiteColor colorWithAlphaComponent:0.5].CGColor;
            layer;
        });

        _animatingRingLayer = ({
            CAShapeLayer * layer = [CAShapeLayer new];
            layer.fillColor = UIColor.blackColor.CGColor;
            layer.lineWidth = kRingWidth;
            layer.path = [circularPath CGPath];
            layer.strokeColor = UIColor.whiteColor.CGColor;
            layer;
        });

        _countdownLabel = ({
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [MPCountdownTimerView intrinsicContentDimension], [MPCountdownTimerView intrinsicContentDimension])];
            label.center = ringCenter;
            label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
            label.text = [NSString stringWithFormat:@"%.0f", ceil(seconds)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = UIColor.whiteColor;
            label;
        });

        [self.layer addSublayer:_backgroundRingLayer];
        [self.layer addSublayer:_animatingRingLayer];
        [self addSubview:_countdownLabel];

        self.userInteractionEnabled = NO;
        self.accessibilityLabel = @"Countdown Timer";
    }

    return self;
}

- (void)dealloc {
    // Stop the timer if the view is going away, but do not notify the completion block
    // if there is one.
    _completionBlock = nil;
    [self stopAndSignalCompletion:NO];
}

#pragma mark - Dimension

+ (CGFloat)intrinsicContentDimension {
    return (kRingRadius + kRingPadding) * 2;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake([MPCountdownTimerView intrinsicContentDimension],
                      [MPCountdownTimerView intrinsicContentDimension]);
}

#pragma mark - Timer

- (BOOL)hasStarted {
    return self.timer != nil;
}

- (void)start {
    if (self.hasStarted) {
        MPLogDebug(@"MPCountdownTimerView cannot start again since it has started");
        return;
    }

    // Observer app state for automatic pausing and resuming
    [self.notificationCenter addObserver:self
                                selector:@selector(pause)
                                    name:UIApplicationDidEnterBackgroundNotification
                                  object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(resume)
                                    name:UIApplicationWillEnterForegroundNotification
                                  object:nil];

    // This animation is the ring disappearing clockwise from full (12 o'clock) to empty.
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.duration = self.remainingSeconds;
    animation.fillMode = kCAFillModeForwards; // for keeping the completed animation
    animation.removedOnCompletion = NO; // for keeping the completed animation
    [self.animatingRingLayer addAnimation:animation forKey:kAnimationKey];

    // Fire the timer
    __typeof__(self) __weak weakSelf = self;
    self.timer = [[MPResumableTimer alloc] initWithInterval:kCountdownTimerInterval repeats:YES runLoopMode:NSDefaultRunLoopMode closure:^(MPResumableTimer *timer) {
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf onTimerUpdate:timer];
    }];

    [self.timer scheduleNow];

    MPLogInfo(@"MPCountdownTimerView started");
}

- (void)stopAndSignalCompletion:(BOOL)shouldSignalCompletion {
    if (!self.hasStarted) {
        MPLogDebug(@"MPCountdownTimerView cannot stop since it has not started yet");
        return;
    }

    // Invalidate and clear the timer to stop it completely. Intentionally not setting `timer` to nil
    // so that the computed var `hasStarted` is still `YES` after the timer stops.
    [self.timer invalidate];

    MPLogInfo(@"MPCountdownTimerView stopped");

    // Notify the completion block and clear it out once it's handling has finished.
    if (shouldSignalCompletion && self.completionBlock != nil) {
        BOOL hasElapsed = (self.remainingSeconds <= 0);
        self.completionBlock(hasElapsed);

        MPLogInfo(@"MPCountdownTimerView completion block notified");
    }

    // Clear out the completion block since the timer has stopped and it is
    // no longer needed for this instance.
    self.completionBlock = nil;
}

- (void)pause {
    if (!self.hasStarted) {
        MPLogDebug(@"MPCountdownTimerView cannot pause since it has not started yet");
        return;
    }

    if (!self.timer.isCountdownActive) {
        MPLogInfo(@"MPCountdownTimerView is already paused");
        return; // avoid wrong animation timing
    }
    [self.timer pause];

    // See documentation for pausing and resuming animation:
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html
    CFTimeInterval pausedTime = [self.animatingRingLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.animatingRingLayer.speed = 0.0;
    self.animatingRingLayer.timeOffset = pausedTime;

    MPLogInfo(@"MPCountdownTimerView paused");
}

- (void)resume {
    if (!self.hasStarted) {
        MPLogDebug(@"MPCountdownTimerView cannot resume since it has not started yet");
        return;
    }

    if (self.timer.isCountdownActive) {
        MPLogInfo(@"MPCountdownTimerView is already running");
        return; // avoid wrong animation timing
    }
    [self.timer scheduleNow];

    // See documentation for pausing and resuming animation:
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html
    CFTimeInterval pausedTime = [self.animatingRingLayer timeOffset];
    self.animatingRingLayer.speed = 1.0;
    self.animatingRingLayer.timeOffset = 0.0;
    self.animatingRingLayer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.animatingRingLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.animatingRingLayer.beginTime = timeSincePause;

    MPLogInfo(@"MPCountdownTimerView resumed");
}

#pragma mark - MPResumableTimer

- (void)onTimerUpdate:(MPResumableTimer *)sender {
    // Update the count.
    self.remainingSeconds -= kCountdownTimerInterval;
    self.countdownLabel.text = [NSString stringWithFormat:@"%.0f", ceil(self.remainingSeconds)];

    // Stop the timer and notify the completion block.
    if (self.remainingSeconds <= 0) {
        [self stopAndSignalCompletion:YES];
    }
}

@end

#pragma mark - MPViewabilityObstruction

@implementation MPCountdownTimerView (MPViewabilityObstruction)

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeOther;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameCountdownTimer;
}

@end

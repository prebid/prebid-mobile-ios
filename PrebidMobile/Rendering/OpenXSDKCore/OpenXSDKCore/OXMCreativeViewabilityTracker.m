//
//  OXMCreativeViewabilityTracker.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMAbstractCreative.h"
#import "OXMCreativeViewabilityTracker.h"
#import "OXMViewExposureChecker.h"
#import "OXMCreativeModel.h"
#import "OXMAdConfiguration.h"
#import "OXMError.h"
#import "OXMMacros.h"

#import "NSTimer+OXAScheduledTimerFactory.h"
#import "OXAWeakTimerTargetBox.h"
#import "UIView+OxmExtensions.h"

#ifdef DEBUG
#   import "OXASDKConfiguration+oxmTestExtension.h"
#endif

@interface OXMCreativeViewabilityTracker()

@property (nonatomic, assign, readonly) NSTimeInterval pollingTimeInterval;
@property (nonatomic, strong, nonnull, readonly) OXMViewExposureChangeHandler onExposureChange;

@property (nonatomic, strong, nonnull, readonly) OXMViewExposureChecker *checker;

@property (nonatomic, strong, nullable) id<OXATimerInterface> timer;
@property (nonatomic, strong, nonnull) OXMViewExposure *lastExposure;

@property (nonatomic, nullable, weak, readonly) UIView *testedView;
@property (nonatomic, assign) BOOL isViewabilityMode;

@end

@implementation OXMCreativeViewabilityTracker

- (instancetype)initWithView:(UIView *)view pollingTimeInterval:(NSTimeInterval)pollingTimeInterval onExposureChange:(OXMViewExposureChangeHandler)onExposureChange {
    self = [super init];
    if (self) {
        _checker = [[OXMViewExposureChecker alloc] initWithView:view];
        _pollingTimeInterval = pollingTimeInterval;
        _lastExposure = [OXMViewExposure zeroExposure];
        _onExposureChange = onExposureChange;
        
        _testedView = view;
        _isViewabilityMode = NO;
    }

    return self;
}

- (instancetype)initWithCreative:(OXMAbstractCreative *)creative {
    @weakify(creative);
    if (self = [self initWithView:creative.view
          pollingTimeInterval:creative.creativeModel.adConfiguration.pollFrequency
             onExposureChange:^(OXMCreativeViewabilityTracker *tracker, OXMViewExposure *viewExposure)
    {
        @strongify(creative);
//        BOOL const isVisible = viewExposure.exposureFactor > 0;
        BOOL isVisible = [tracker isVisibleView:tracker.testedView];
        [creative onViewabilityChanged:isVisible viewExposure:viewExposure];
    }]) {
        _isViewabilityMode = YES;
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    [self stop];
    OXAScheduledTimerFactory const timerFatory = [OXAWeakTimerTargetBox
                                                  scheduledTimerFactoryWithWeakifiedTarget:[NSTimer
                                                                                            oxaScheduledTimerFactory]];
    self.timer = timerFatory(self.pollingTimeInterval, self, @selector(checkViewability), nil, YES);
}

- (void)checkViewability {
    
    //don't waste time for exposure calculation
    //when it unneeded
    if (self.isViewabilityMode) {
        self.onExposureChange(self, self.lastExposure);
        return;
    }
    
    //TODO: check visibility using viewableDuration and area in future
    [self checkExposureWithForce:NO];
}

- (void)checkExposureWithForce:(BOOL)isForce {
    OXMViewExposure * const newExposure = self.checker.exposure;
    
    if (isForce || ![newExposure isEqual:self.lastExposure]) {
        self.lastExposure = newExposure;
        self.onExposureChange(self, newExposure);
    }
}

- (BOOL)isVisibleView:(UIView *)view {
#ifdef DEBUG
    if ([OXASDKConfiguration singleton].forcedIsViewable) {
        return YES;
    }
#endif
    if (!view) {
        return NO;
    }
    
    return [view oxmIsVisibleInViewLegacy:view.superview] && view.window != nil;
}

- (void)stop {
    [self.timer invalidate];
}

@end

//
//  PBMCreativeViewabilityTracker.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMAbstractCreative.h"
#import "PBMCreativeViewabilityTracker.h"
#import "PBMViewExposureChecker.h"
#import "PBMCreativeModel.h"
#import "PBMAdConfiguration.h"
#import "PBMError.h"
#import "PBMMacros.h"

#import "NSTimer+PBMScheduledTimerFactory.h"
#import "PBMWeakTimerTargetBox.h"
#import "UIView+PBMExtensions.h"

#ifdef DEBUG
    #import "PrebidRenderingConfig+TestExtension.h"
    #import "PrebidMobileRenderingSwiftHeaders.h"
    #import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>
#endif

@interface PBMCreativeViewabilityTracker()

@property (nonatomic, assign, readonly) NSTimeInterval pollingTimeInterval;
@property (nonatomic, strong, nonnull, readonly) PBMViewExposureChangeHandler onExposureChange;

@property (nonatomic, strong, nonnull, readonly) PBMViewExposureChecker *checker;

@property (nonatomic, strong, nullable) id<PBMTimerInterface> timer;
@property (nonatomic, strong, nonnull) PBMViewExposure *lastExposure;

@property (nonatomic, nullable, weak, readonly) UIView *testedView;
@property (nonatomic, assign) BOOL isViewabilityMode;

@end

@implementation PBMCreativeViewabilityTracker

- (instancetype)initWithView:(UIView *)view pollingTimeInterval:(NSTimeInterval)pollingTimeInterval onExposureChange:(PBMViewExposureChangeHandler)onExposureChange {
    self = [super init];
    if (self) {
        _checker = [[PBMViewExposureChecker alloc] initWithView:view];
        _pollingTimeInterval = pollingTimeInterval;
        _lastExposure = [PBMViewExposure zeroExposure];
        _onExposureChange = onExposureChange;
        
        _testedView = view;
        _isViewabilityMode = NO;
    }

    return self;
}

- (instancetype)initWithCreative:(PBMAbstractCreative *)creative {
    @weakify(creative);
    if (self = [self initWithView:creative.view
          pollingTimeInterval:creative.creativeModel.adConfiguration.pollFrequency
             onExposureChange:^(PBMCreativeViewabilityTracker *tracker, PBMViewExposure *viewExposure)
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
    PBMScheduledTimerFactory const timerFatory = [PBMWeakTimerTargetBox
                                                  scheduledTimerFactoryWithWeakifiedTarget:[NSTimer
                                                                                            pbmScheduledTimerFactory]];
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
    PBMViewExposure * const newExposure = self.checker.exposure;
    
    if (isForce || ![newExposure isEqual:self.lastExposure]) {
        self.lastExposure = newExposure;
        self.onExposureChange(self, newExposure);
    }
}

- (BOOL)isVisibleView:(UIView *)view {
#ifdef DEBUG
    if (PrebidRenderingConfig.shared.forcedIsViewable) {
        return YES;
    }
#endif
    if (!view) {
        return NO;
    }
    
    return [view pbmIsVisibleInViewLegacy:view.superview] && view.window != nil;
}

- (void)stop {
    [self.timer invalidate];
}

@end

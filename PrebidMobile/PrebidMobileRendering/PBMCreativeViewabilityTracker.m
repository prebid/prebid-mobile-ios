/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMAbstractCreative.h"
#import "PBMCreativeViewabilityTracker.h"
#import "PBMViewExposureChecker.h"
#import "PBMCreativeModel.h"
#import "PBMError.h"
#import "PBMMacros.h"

#import "NSTimer+PBMScheduledTimerFactory.h"
#import "PBMWeakTimerTargetBox.h"
#import "UIView+PBMExtensions.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#ifdef DEBUG
    #import "Prebid+TestExtension.h"
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
    if (Prebid.shared.forcedIsViewable) {
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

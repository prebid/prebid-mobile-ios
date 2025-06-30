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

#import "PBMViewExposureChecker.h"
#import "PBMMacros.h"

#import "NSTimer+PBMScheduledTimerFactory.h"
#import "PBMWeakTimerTargetBox.h"
#import "UIView+PBMExtensions.h"

#import "SwiftImport.h"

#ifdef DEBUG
    #import "Prebid+TestExtension.h"
#endif

typedef void(^PBMViewExposureChangeHandler)(id<PBMCreativeViewabilityTracker> tracker, id<PBMViewExposure> viewExposure);

@interface PBMCreativeViewabilityTracker_Objc : NSObject <PBMCreativeViewabilityTracker>

@property (nonatomic, assign, readonly) NSTimeInterval pollingTimeInterval;
@property (nonatomic, strong, nonnull, readonly) PBMViewExposureChangeHandler onExposureChange;

@property (nonatomic, strong, nonnull, readonly) PBMViewExposureChecker *checker;

@property (nonatomic, strong, nullable) id<PBMTimerInterface> timer;
@property (nonatomic, strong, nonnull) id<PBMViewExposure> lastExposure;

@property (nonatomic, nullable, weak, readonly) UIView *testedView;
@property (nonatomic, assign) BOOL isViewabilityMode;

@end

@implementation PBMCreativeViewabilityTracker_Objc

- (instancetype)initWithView:(UIView *)view
         pollingTimeInterval:(NSTimeInterval)pollingTimeInterval
            onExposureChange:(PBMViewExposureChangeHandler)onExposureChange {
    self = [super init];
    if (self) {
        _checker = [[PBMViewExposureChecker alloc] initWithView:view];
        _pollingTimeInterval = pollingTimeInterval;
        _lastExposure = [PBMFactory.ViewExposureType zeroExposure];
        _onExposureChange = onExposureChange;
        
        _testedView = view;
        _isViewabilityMode = NO;
    }

    return self;
}

- (instancetype)initWithCreative:(id<PBMAbstractCreative>)creative {
    @weakify(creative);
    if (self = [self initWithView:creative.view
          pollingTimeInterval:creative.creativeModel.adConfiguration.pollFrequency
             onExposureChange:^(id<PBMCreativeViewabilityTracker> tracker, id<PBMViewExposure> viewExposure)
    {
        @strongify(creative);
        __auto_type objcTracker = (PBMCreativeViewabilityTracker_Objc *)tracker;
        if (![tracker isKindOfClass:PBMCreativeViewabilityTracker_Objc.class]) {
            return;
        }
        
        BOOL isVisible = [objcTracker isVisibleView:objcTracker.testedView];
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
    id<PBMViewExposure> const newExposure = self.checker.exposure;
    
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

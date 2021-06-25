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

#import "PBMNativeImpressionsDetector.h"

#import "PBMPollingBlock.h"
#import "PBMViewabilityEventDetector.h"
#import "PBMViewExposureProviders.h"
#import "PBMMacros.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>


@interface PBMNativeImpressionsDetector ()

@property (nonatomic, strong, nullable) PBMPollingBlock checkRenderedImpression;
@property (nonatomic, strong, nullable) PBMPollingBlock checkViewableImpressions;

@end



@implementation PBMNativeImpressionsDetector

- (instancetype)initWithView:(UIView *)view
  impressionDetectionHandler:(PBMNativeImpressionDetectionHandler)impressionDetectionHandler
    onLastImpressionDetected:(PBMVoidBlock)onLastImpressionDetected
{
    if (!(self = [super init])) {
        return nil;
    }
    @weakify(self);
    PBMVoidBlock const checkAllImpressionsReported = ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        if (self.checkRenderedImpression == nil && self.checkViewableImpressions == nil) {
            onLastImpressionDetected();
        }
    };
    
    PBMViewabilityEventDetector * const renderedImpressionDetector = [[PBMViewabilityEventDetector alloc]
                                                                      initWithViewabilityEvents:@[
        [PBMNativeImpressionsDetector renderedImpressionEventWithCallback:^{
            impressionDetectionHandler(NativeEventTypeImpression);
        }],
    ] onLastEventDetected:^{
        @strongify(self);
        self.checkRenderedImpression = nil;
        checkAllImpressionsReported();
    }];
    
    PBMViewabilityEventDetector * const viewableImpressionsDetector = [[PBMViewabilityEventDetector alloc]
                                                                       initWithViewabilityEvents:@[
        [PBMNativeImpressionsDetector mrc50ImpressionEventWithCallback:^{
            impressionDetectionHandler(NativeEventTypeMrc50);
        }],
        [PBMNativeImpressionsDetector mrc100ImpressionEventWithCallback:^{
            impressionDetectionHandler(NativeEventTypeMrc100);
        }],
        [PBMNativeImpressionsDetector video50ImpressionEventWithCallback:^{
            impressionDetectionHandler(NativeEventTypeVideo50);
        }],
    ] onLastEventDetected:^{
        @strongify(self);
        self.checkViewableImpressions = nil;
        checkAllImpressionsReported();
    }];
    
    PBMViewExposureProvider const renderedImpressionExposureProvider = [PBMViewExposureProviders
                                                                        visibilityAsExposureForView:view];
    PBMViewExposureProvider const viewableImpressionExposureProvider = [PBMViewExposureProviders
                                                                        viewExposureForView:view];
    
    _checkRenderedImpression = ^(NSTimeInterval timeSinceLastPolling) {
        [renderedImpressionDetector onExposureMeasured:renderedImpressionExposureProvider().exposureFactor
                            passedSinceLastMeasurement:timeSinceLastPolling];
    };
    _checkViewableImpressions = ^(NSTimeInterval timeSinceLastPolling) {
        [viewableImpressionsDetector onExposureMeasured:viewableImpressionExposureProvider().exposureFactor
                             passedSinceLastMeasurement:timeSinceLastPolling];
    };
    
    return self;
}

- (void)checkViewabilityWithTimeSinceLastCheck:(NSTimeInterval)timeSinceLastCheck {
    if (self.checkRenderedImpression) {
        self.checkRenderedImpression(timeSinceLastCheck);
    }
    if (self.checkViewableImpressions) {
        self.checkViewableImpressions(timeSinceLastCheck);
    }
}

// MARK: - Private Helpers

+ (PBMViewabilityEvent *)renderedImpressionEventWithCallback:(PBMVoidBlock)callback {
    return [[PBMViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor > 0;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return YES;
    } onEventDetected:callback];
}

+ (PBMViewabilityEvent *)mrc50ImpressionEventWithCallback:(PBMVoidBlock)callback {
    return [[PBMViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 0.5;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 1.0;
    } onEventDetected:callback];
}

+ (PBMViewabilityEvent *)mrc100ImpressionEventWithCallback:(PBMVoidBlock)callback {
    return [[PBMViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 1.0;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 1.0;
    } onEventDetected:callback];
}

+ (PBMViewabilityEvent *)video50ImpressionEventWithCallback:(PBMVoidBlock)callback {
    return [[PBMViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 0.5;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 2.0;
    } onEventDetected:callback];
}

@end

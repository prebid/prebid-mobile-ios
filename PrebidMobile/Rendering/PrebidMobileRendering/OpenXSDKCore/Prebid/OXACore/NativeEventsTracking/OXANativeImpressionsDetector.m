//
//  OXANativeImpressionsDetector.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeImpressionsDetector.h"

#import "OXAPollingBlock.h"
#import "OXAViewabilityEventDetector.h"
#import "OXAViewExposureProviders.h"
#import "OXMMacros.h"


@interface OXANativeImpressionsDetector ()

@property (nonatomic, strong, nullable) OXAPollingBlock checkRenderedImpression;
@property (nonatomic, strong, nullable) OXAPollingBlock checkViewableImpressions;

@end



@implementation OXANativeImpressionsDetector

- (instancetype)initWithView:(UIView *)view
  impressionDetectionHandler:(OXANativeImpressionDetectionHandler)impressionDetectionHandler
    onLastImpressionDetected:(OXMVoidBlock)onLastImpressionDetected
{
    if (!(self = [super init])) {
        return nil;
    }
    @weakify(self);
    OXMVoidBlock const checkAllImpressionsReported = ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        if (self.checkRenderedImpression == nil && self.checkViewableImpressions == nil) {
            onLastImpressionDetected();
        }
    };
    
    OXAViewabilityEventDetector * const renderedImpressionDetector = [[OXAViewabilityEventDetector alloc]
                                                                      initWithViewabilityEvents:@[
        [OXANativeImpressionsDetector renderedImpressionEventWithCallback:^{
            impressionDetectionHandler(OXANativeEventType_Impression);
        }],
    ] onLastEventDetected:^{
        @strongify(self);
        self.checkRenderedImpression = nil;
        checkAllImpressionsReported();
    }];
    
    OXAViewabilityEventDetector * const viewableImpressionsDetector = [[OXAViewabilityEventDetector alloc]
                                                                       initWithViewabilityEvents:@[
        [OXANativeImpressionsDetector mrc50ImpressionEventWithCallback:^{
            impressionDetectionHandler(OXANativeEventType_MRC50);
        }],
        [OXANativeImpressionsDetector mrc100ImpressionEventWithCallback:^{
            impressionDetectionHandler(OXANativeEventType_MRC100);
        }],
        [OXANativeImpressionsDetector video50ImpressionEventWithCallback:^{
            impressionDetectionHandler(OXANativeEventType_Video50);
        }],
    ] onLastEventDetected:^{
        @strongify(self);
        self.checkViewableImpressions = nil;
        checkAllImpressionsReported();
    }];
    
    OXAViewExposureProvider const renderedImpressionExposureProvider = [OXAViewExposureProviders
                                                                        visibilityAsExposureForView:view];
    OXAViewExposureProvider const viewableImpressionExposureProvider = [OXAViewExposureProviders
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

+ (OXAViewabilityEvent *)renderedImpressionEventWithCallback:(OXMVoidBlock)callback {
    return [[OXAViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor > 0;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return YES;
    } onEventDetected:callback];
}

+ (OXAViewabilityEvent *)mrc50ImpressionEventWithCallback:(OXMVoidBlock)callback {
    return [[OXAViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 0.5;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 1.0;
    } onEventDetected:callback];
}

+ (OXAViewabilityEvent *)mrc100ImpressionEventWithCallback:(OXMVoidBlock)callback {
    return [[OXAViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 1.0;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 1.0;
    } onEventDetected:callback];
}

+ (OXAViewabilityEvent *)video50ImpressionEventWithCallback:(OXMVoidBlock)callback {
    return [[OXAViewabilityEvent alloc] initWithExposureSatisfactionCheck:^BOOL(float exposureFactor) {
        return exposureFactor >= 0.5;
    } durationSatisfactionCheck:^BOOL(NSTimeInterval exposureDuration) {
        return exposureDuration >= 2.0;
    } onEventDetected:callback];
}

@end

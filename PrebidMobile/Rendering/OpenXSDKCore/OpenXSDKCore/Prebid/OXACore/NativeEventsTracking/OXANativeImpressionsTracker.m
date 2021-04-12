//
//  OXANativeImpressionsTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeImpressionsTracker.h"

#import "OXANativeImpressionsDetector.h"
#import "OXAPollingTimer.h"
#import "OXMMacros.h"


@interface OXANativeImpressionsTracker ()
@property (nonatomic, strong, nullable) OXAPollingTimer *pollingTimer;
@end



@implementation OXANativeImpressionsTracker

- (instancetype)initWithView:(UIView *)view
             pollingInterval:(NSTimeInterval)pollingInterval
       scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
  impressionDetectionHandler:(OXANativeImpressionDetectionHandler)impressionDetectionHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    
    @weakify(self);
    OXANativeImpressionsDetector * const detector = [[OXANativeImpressionsDetector alloc] initWithView:view
                                                                            impressionDetectionHandler:impressionDetectionHandler
                                                                              onLastImpressionDetected:^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        self.pollingTimer = nil;
    }];
    
    _pollingTimer = [[OXAPollingTimer alloc] initWithPollingInterval:pollingInterval
                                               scheduledTimerFactory:scheduledTimerFactory
                                                        pollingBlock:^(NSTimeInterval timeSinceLastPolling) {
        [detector checkViewabilityWithTimeSinceLastCheck:timeSinceLastPolling];
    }];
    
    return self;
}

@end

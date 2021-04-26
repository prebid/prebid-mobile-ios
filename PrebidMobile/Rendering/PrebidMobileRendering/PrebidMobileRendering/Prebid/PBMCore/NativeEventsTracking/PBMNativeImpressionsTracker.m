//
//  PBMNativeImpressionsTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeImpressionsTracker.h"

#import "PBMNativeImpressionsDetector.h"
#import "PBMPollingTimer.h"
#import "PBMMacros.h"


@interface PBMNativeImpressionsTracker ()
@property (nonatomic, strong, nullable) PBMPollingTimer *pollingTimer;
@end



@implementation PBMNativeImpressionsTracker

- (instancetype)initWithView:(UIView *)view
             pollingInterval:(NSTimeInterval)pollingInterval
       scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
  impressionDetectionHandler:(PBMNativeImpressionDetectionHandler)impressionDetectionHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    
    @weakify(self);
    PBMNativeImpressionsDetector * const detector = [[PBMNativeImpressionsDetector alloc] initWithView:view
                                                                            impressionDetectionHandler:impressionDetectionHandler
                                                                              onLastImpressionDetected:^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        self.pollingTimer = nil;
    }];
    
    _pollingTimer = [[PBMPollingTimer alloc] initWithPollingInterval:pollingInterval
                                               scheduledTimerFactory:scheduledTimerFactory
                                                        pollingBlock:^(NSTimeInterval timeSinceLastPolling) {
        [detector checkViewabilityWithTimeSinceLastCheck:timeSinceLastPolling];
    }];
    
    return self;
}

@end

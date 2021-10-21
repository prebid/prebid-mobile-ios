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

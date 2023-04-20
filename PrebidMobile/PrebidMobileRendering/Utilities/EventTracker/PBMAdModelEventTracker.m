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

#import "PBMAdModelEventTracker.h"
#import "PBMCreativeModel.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMAdModelEventTracker()

@property (nonatomic, weak) PBMCreativeModel *creativeModel;
@property (nonatomic, strong) id<PrebidServerConnectionProtocol> serverConnection;

@end

@implementation PBMAdModelEventTracker

#pragma mark - Initialization

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                     serverConnection:(id<PrebidServerConnectionProtocol>)serverConnection {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
    }
    
    return self;
}

#pragma mark - PBMEventTrackerProtocol

// Tracking Firing
- (void)trackEvent:(PBMTrackingEvent)event {
    NSString *eventName = [PBMTrackingEventDescription getDescription:event];
    PBMAssert(eventName);
    if (!eventName) {
        return;
    }
    
    NSArray *urls = self.creativeModel.trackingURLs[eventName];
    if (!urls) {
        PBMLogInfo(@"No tracking URL(s) for event %@", eventName);
        return;
    }
    
    for (NSString *url in urls) {
        [self.serverConnection fireAndForget:url];
    }
}

- (void)trackVideoAdLoaded:(PBMVideoVerificationParameters *)parameters {
}

- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    [self trackEvent:PBMTrackingEventStart];
}

- (void)trackVolumeChanged:(CGFloat)volume deviceVolume:(CGFloat)deviceVolume{
}

@end

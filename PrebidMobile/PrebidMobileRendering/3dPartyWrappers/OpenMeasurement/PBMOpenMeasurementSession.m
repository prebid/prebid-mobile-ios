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

#import "PBMOpenMeasurementSession.h"
#import "PBMOpenMeasurementEventTracker.h"
#import "PBMOpenMeasurementFriendlyObstructionTypeBridge.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import <OMIDAdSession.h>

@interface PBMOpenMeasurementSession ()

@property (nonatomic, strong) OMIDPrebidorgAdSession *session;

@property (nonatomic, strong) id<PBMEventTrackerProtocol> eventTracker;

@end

@implementation PBMOpenMeasurementSession

#pragma mark - Initialization

- (instancetype)initWithContext:(OMIDPrebidorgAdSessionContext *)context
                  configuration:(OMIDPrebidorgAdSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        if ([self initializeOMSessionWithContext:context configuration:configuration]) {
            // IMPORTANT: Event tracker must be created before session start
            // Otherwise, tracking of video events will be unavailable.
            self.eventTracker = [[PBMOpenMeasurementEventTracker alloc] initWithSession:self.session];
        } else {
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    
    // According to OM requirements, the WebView should live at least 1 sec to send all needed events.
    // https://interactiveadvertisingbureau.github.io/Open-Measurement-SDKiOS/#7-stop-the-session
    
    UIView *view = self.session.mainAdView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        (void) view;
    });
    
    [self stop];
}

#pragma mark - PBMOpenMeasurementSessionProtocol

- (void)setupMainView:(UIView *)mainView {
    if (!self.session) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    self.session.mainAdView = mainView;
}

- (void)start {
    if (!self.session) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    [self.session start];
}

- (void)stop {
    if (!self.session) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    [self.session finish];
    self.session = nil;
}

- (void)addFriendlyObstruction:(nonnull UIView *)friendlyObstruction purpose:(PBMOpenMeasurementFriendlyObstructionPurpose)purpose {
    if (!self.session) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    OMIDFriendlyObstructionType convertedPurpose = [PBMOpenMeasurementFriendlyObstructionTypeBridge obstructionTypeOfObstructionPurpose:purpose];
    NSString *detailedReason = [PBMOpenMeasurementFriendlyObstructionTypeBridge describeFriendlyObstructionPurpose:purpose];
    
    NSError *error = nil;
    
    [self.session addFriendlyObstruction:friendlyObstruction
                                 purpose:convertedPurpose
                          detailedReason:detailedReason
                                   error:&error];
    
    if (error != nil) {
        PBMLogError(@"%@", [error localizedDescription]);
    }
}

#pragma mark - Internal Methods

- (BOOL)initializeOMSessionWithContext:(OMIDPrebidorgAdSessionContext *)context
                         configuration:(OMIDPrebidorgAdSessionConfiguration *)configuration {
    NSError *sessionError;
    self.session = [[OMIDPrebidorgAdSession alloc] initWithConfiguration:configuration
                                                    adSessionContext:context
                                                               error:&sessionError];
    if (sessionError) {
        PBMLogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
    }
    
    return self.session != nil;
}

@end

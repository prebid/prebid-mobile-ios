//
//  PBMOpenMeasurementSession.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMLog.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMOpenMeasurementEventTracker.h"
#import "PBMOpenMeasurementFriendlyObstructionTypeBridge.h"

@import OMSDK_Openx;

@interface PBMOpenMeasurementSession ()

@property (nonatomic, strong) OMIDOpenxAdSession *session;

@property (nonatomic, strong) id<PBMEventTrackerProtocol> eventTracker;

@end

@implementation PBMOpenMeasurementSession

#pragma mark - Initialization

- (instancetype)initWithContext:(OMIDOpenxAdSessionContext *)context
                  configuration:(OMIDOpenxAdSessionConfiguration *)configuration {
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

- (BOOL)initializeOMSessionWithContext:(OMIDOpenxAdSessionContext *)context
                         configuration:(OMIDOpenxAdSessionConfiguration *)configuration {
    NSError *sessionError;
    self.session = [[OMIDOpenxAdSession alloc] initWithConfiguration:configuration
                                                    adSessionContext:context
                                                               error:&sessionError];
    if (sessionError) {
        PBMLogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
    }
    
    return self.session != nil;
}

@end

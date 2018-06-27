//
//  MPViewabilityAdapterAvid.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPLogging.h"
#import "MPViewabilityAdapterAvid.h"

#if __has_include("MoPub_Avid.h")
#import "MoPub_Avid.h"
#define __HAS_AVID_LIB_
#endif

@interface MPViewabilityAdapterAvid()
@property (nonatomic, readwrite) BOOL isTracking;

#ifdef __HAS_AVID_LIB_
@property (nonatomic, strong) MoPub_AbstractAvidAdSession * avidAdSession;
#endif
@end

@implementation MPViewabilityAdapterAvid

- (instancetype)initWithAdView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = NO;

#ifdef __HAS_AVID_LIB_
        MoPub_ExternalAvidAdSessionContext * avidAdSessionContext = [MoPub_ExternalAvidAdSessionContext contextWithPartnerVersion:[[MoPub sharedInstance] version] isDeferred:!startTracking];
        if (isVideo) {
            _avidAdSession = [MoPub_AvidAdSessionManager startAvidVideoAdSessionWithContext:avidAdSessionContext];
        }
        else {
            _avidAdSession = [MoPub_AvidAdSessionManager startAvidDisplayAdSessionWithContext:avidAdSessionContext];
        }

        [_avidAdSession registerAdView:webView];

        if (startTracking) {
            _isTracking = YES;
            MPLogInfo(@"[Viewability] IAS tracking started");
        }
#endif
    }

    return self;
}

- (void)startTracking {
#ifdef __HAS_AVID_LIB_
    // Only start tracking if:
    // 1. Avid is not already tracking
    // 2. Avid session is valid
    if (!self.isTracking && self.avidAdSession != nil) {
        [self.avidAdSession.avidDeferredAdSessionListener recordReadyEvent];
        self.isTracking = YES;
        MPLogInfo(@"[Viewability] IAS tracking started");
    }
#endif
}

- (void)stopTracking {
#ifdef __HAS_AVID_LIB_
    // Only stop tracking if:
    // 1. IAS is already tracking
    if (self.isTracking) {
        [self.avidAdSession endSession];
        if (self.avidAdSession) {
            MPLogInfo(@"[Viewability] IAS tracking stopped");
        }
    }

    // Mark IAS as not tracking
    self.isTracking = NO;
#endif
}

- (void)registerFriendlyObstructionView:(UIView *)view {
#ifdef __HAS_AVID_LIB_
    [self.avidAdSession registerFriendlyObstruction:view];
#endif
}

@end

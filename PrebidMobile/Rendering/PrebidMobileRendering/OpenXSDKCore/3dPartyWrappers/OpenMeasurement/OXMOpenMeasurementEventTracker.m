//
//  OXMOpenMeasurementEventTracker.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMLog.h"

#import "OXMOpenMeasurementEventTracker.h"
#import "OXMEventTrackerProtocol.h"
#import "OXMVideoVerificationParameters.h"

@import OMSDK_Openx;

@interface OXMOpenMeasurementEventTracker()

@property (nonatomic, strong) OMIDOpenxAdSession *session;

@property (nonatomic, strong) OMIDOpenxAdEvents *adEvents;
@property (nonatomic, strong) OMIDOpenxMediaEvents *mediaEvents;

@end

@implementation OXMOpenMeasurementEventTracker

- (instancetype)initWithSession:(OMIDOpenxAdSession *)session {
    self = [super init];
    if (self) {
        self.session = session;
        [self initOMEventTrackers];
    }
    
    return self;
}

- (void)trackEvent:(OXMTrackingEvent)event {
    if (!self.session) {
        OXMLogError(@"Measurement Session is missed.");
        return;
    }
    
    switch (event) {
        case OXMTrackingEventLoaded         : [self trackAdLoaded]; break;
        case OXMTrackingEventImpression     : [self trackImpression]; break;
            
        case OXMTrackingEventClick          : [self.mediaEvents adUserInteractionWithType:OMIDInteractionTypeClick]; break;
        case OXMTrackingEventCompanionClick : [self.mediaEvents adUserInteractionWithType:OMIDInteractionTypeClick]; break;

        case OXMTrackingEventFirstQuartile  : [self.mediaEvents firstQuartile]; break;
        case OXMTrackingEventMidpoint       : [self.mediaEvents midpoint];break;
        case OXMTrackingEventThirdQuartile  : [self.mediaEvents thirdQuartile];break;
        case OXMTrackingEventComplete       : [self.mediaEvents complete];break;
        case OXMTrackingEventPause          : [self.mediaEvents pause]; break;
        case OXMTrackingEventResume         : [self.mediaEvents resume]; break;
        case OXMTrackingEventSkip           : [self.mediaEvents skipped]; break;
        
        // Are not supported in the current implementation. All video ads are shown in fullscreen mode without options.
        case OXMTrackingEventFullscreen     : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateFullscreen]; break;
        case OXMTrackingEventExitFullscreen : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateNormal]; break;
        case OXMTrackingEventNormal         : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateNormal]; break;
        case OXMTrackingEventCollapse       : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateCollapsed]; break;
        case OXMTrackingEventExpand         : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateExpanded]; break;
            
        default:
            break;
    }
}

- (void)trackAdLoaded {
    NSError *error = nil;
    [self.adEvents loadedWithError:&error];
    if (error != nil) {
        OXMLogError(@"%@", [error localizedDescription]);
    }
}

- (void)trackVideoAdLoaded:(OXMVideoVerificationParameters *)parameters {
    NSError *error = nil;
    [self.adEvents loadedWithVastProperties:[[OMIDOpenxVASTProperties alloc] initWithAutoPlay:parameters.autoPlay position:OMIDPositionStandalone] error:&error];
    if (error != nil) {
        OXMLogError(@"%@", [error localizedDescription]);
    }
}

- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume {
    [self.mediaEvents startWithDuration:duration mediaPlayerVolume:volume];
}

- (void)trackVolumeChanged:(CGFloat)volume deviceVolume:(CGFloat)deviceVolume {
    [self.mediaEvents volumeChangeTo:volume];
}

#pragma mark - Internal Methods

- (void)initOMEventTrackers {
    
    NSError *adEventsError;
    self.adEvents = [[OMIDOpenxAdEvents alloc] initWithAdSession:self.session error:&adEventsError];
    if (adEventsError) {
        OXMLogError(@"Open Measurement can't create ad events with error: %@", [adEventsError localizedDescription]);
    }
    
    if (self.session.configuration.mediaEventsOwner == OMIDNativeOwner) {
        NSError *videoEventsError;
        self.mediaEvents = [[OMIDOpenxMediaEvents alloc] initWithAdSession:self.session error:&videoEventsError];
        if (videoEventsError) {
            OXMLogError(@"Open Measurement can't create video events with error: %@", [videoEventsError localizedDescription]);
        }
    }
}

#pragma mark - Tracking Methods

- (void)trackImpression {
    NSError *impError;
    [self.adEvents impressionOccurredWithError:&impError];
    if (impError) {
        OXMLogError(@"Open Measurement can't track impression with error: %@", [impError localizedDescription]);
    }
}

@end

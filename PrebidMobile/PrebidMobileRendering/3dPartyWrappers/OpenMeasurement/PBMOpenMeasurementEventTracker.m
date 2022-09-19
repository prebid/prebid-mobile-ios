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

#import "PBMOpenMeasurementEventTracker.h"
#import "PBMEventTrackerProtocol.h"
#import "PBMVideoVerificationParameters.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import <OMIDAdSession.h>
#import <OMIDAdEvents.h>
#import <OMIDMediaEvents.h>

@interface PBMOpenMeasurementEventTracker()

@property (nonatomic, strong) OMIDPrebidorgAdSession *session;

@property (nonatomic, strong) OMIDPrebidorgAdEvents *adEvents;
@property (nonatomic, strong) OMIDPrebidorgMediaEvents *mediaEvents;

@end

@implementation PBMOpenMeasurementEventTracker

- (instancetype)initWithSession:(OMIDPrebidorgAdSession *)session {
    self = [super init];
    if (self) {
        self.session = session;
        [self initOMEventTrackers];
    }
    
    return self;
}

- (void)trackEvent:(PBMTrackingEvent)event {
    if (!self.session) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    switch (event) {
        case PBMTrackingEventLoaded         : [self trackAdLoaded]; break;
        case PBMTrackingEventImpression     : [self trackImpression]; break;
            
        case PBMTrackingEventClick          : [self.mediaEvents adUserInteractionWithType:OMIDInteractionTypeClick]; break;
        case PBMTrackingEventCompanionClick : [self.mediaEvents adUserInteractionWithType:OMIDInteractionTypeClick]; break;

        case PBMTrackingEventFirstQuartile  : [self.mediaEvents firstQuartile]; break;
        case PBMTrackingEventMidpoint       : [self.mediaEvents midpoint];break;
        case PBMTrackingEventThirdQuartile  : [self.mediaEvents thirdQuartile];break;
        case PBMTrackingEventComplete       : [self.mediaEvents complete];break;
        case PBMTrackingEventPause          : [self.mediaEvents pause]; break;
        case PBMTrackingEventResume         : [self.mediaEvents resume]; break;
        case PBMTrackingEventSkip           : [self.mediaEvents skipped]; break;
        
        // Are not supported in the current implementation. All video ads are shown in fullscreen mode without options.
        case PBMTrackingEventFullscreen     : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateFullscreen]; break;
        case PBMTrackingEventExitFullscreen : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateNormal]; break;
        case PBMTrackingEventNormal         : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateNormal]; break;
        case PBMTrackingEventCollapse       : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateCollapsed]; break;
        case PBMTrackingEventExpand         : [self.mediaEvents playerStateChangeTo:OMIDPlayerStateExpanded]; break;
            
        default:
            break;
    }
}

- (void)trackAdLoaded {
    NSError *error = nil;
    [self.adEvents loadedWithError:&error];
    if (error != nil) {
        PBMLogError(@"%@", [error localizedDescription]);
    }
}

- (void)trackVideoAdLoaded:(PBMVideoVerificationParameters *)parameters {
    NSError *error = nil;
    [self.adEvents loadedWithVastProperties:[[OMIDPrebidorgVASTProperties alloc] initWithAutoPlay:parameters.autoPlay position:OMIDPositionStandalone] error:&error];
    if (error != nil) {
        PBMLogError(@"%@", [error localizedDescription]);
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
    self.adEvents = [[OMIDPrebidorgAdEvents alloc] initWithAdSession:self.session error:&adEventsError];
    if (adEventsError) {
        PBMLogError(@"Open Measurement can't create ad events with error: %@", [adEventsError localizedDescription]);
    }
    
    if (self.session.configuration.mediaEventsOwner == OMIDNativeOwner) {
        NSError *videoEventsError;
        self.mediaEvents = [[OMIDPrebidorgMediaEvents alloc] initWithAdSession:self.session error:&videoEventsError];
        if (videoEventsError) {
            PBMLogError(@"Open Measurement can't create video events with error: %@", [videoEventsError localizedDescription]);
        }
    }
}

#pragma mark - Tracking Methods

- (void)trackImpression {
    NSError *impError;
    [self.adEvents impressionOccurredWithError:&impError];
    if (impError) {
        PBMLogError(@"Open Measurement can't track impression with error: %@", [impError localizedDescription]);
    }
}

@end

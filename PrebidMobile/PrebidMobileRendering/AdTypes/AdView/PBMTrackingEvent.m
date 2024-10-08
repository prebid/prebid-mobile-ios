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

#import "PBMTrackingEvent.h"

@implementation PBMTrackingEventDescription

+ (NSString *)getDescription:(PBMTrackingEvent)event {
    switch (event) {
        case PBMTrackingEventRequest            : return @"creativeModelTrackingKey_Request";
        case PBMTrackingEventImpression         : return @"creativeModelTrackingKey_Impression";
        case PBMTrackingEventClick              : return @"creativeModelTrackingKey_Click";
        case PBMTrackingEventOverlayClick       : return @"creativeModelTrackingKey_OverlayClick";
        case PBMTrackingEventCompanionClick     : return @"creativeModelTrackingKey_CompanionClick";
        case PBMTrackingEventPlay               : return @"creativeModelTrackingKey_Play";
        case PBMTrackingEventPause              : return @"pause";
        case PBMTrackingEventRewind             : return @"rewind";
        case PBMTrackingEventResume             : return @"resume";
        case PBMTrackingEventSkip               : return @"creativeModelTrackingKey_Skip";
        case PBMTrackingEventCreativeView       : return @"creativeView";
        case PBMTrackingEventStart              : return @"start";
        case PBMTrackingEventFirstQuartile      : return @"firstQuartile";
        case PBMTrackingEventMidpoint           : return @"midpoint";
        case PBMTrackingEventThirdQuartile      : return @"thirdQuartile";
        case PBMTrackingEventComplete           : return @"complete";
        case PBMTrackingEventMute               : return @"mute";
        case PBMTrackingEventUnmute             : return @"unmute";
        case PBMTrackingEventFullscreen         : return @"fullscreen";
        case PBMTrackingEventExitFullscreen     : return @"creativeModelTrackingKey_ExitFullscreen";
        case PBMTrackingEventNormal             : return @"normal";
        case PBMTrackingEventExpand             : return @"expand";
        case PBMTrackingEventCollapse           : return @"collapse";
        case PBMTrackingEventCloseLinear        : return @"close";
        case PBMTrackingEventCloseOverlay       : return @"creativeModelTrackingKey_CloseOverlay";
        case PBMTrackingEventError              : return @"creativeModelTrackingKey_Error";
        case PBMTrackingEventAcceptInvitation   : return @"acceptInvitation";
        case PBMTrackingEventLoaded             : return @"loaded";
        case PBMTrackingEventPrebidWin          : return @"prebid_Win";
        case PBMTrackingEventUnknown            : return @"unknown";
    }
}

+ (PBMTrackingEvent)getEventWith:(NSString *)description {
    PBMTrackingEvent event;

    if ([description isEqualToString:@"creativeModelTrackingKey_Request"]) {
        event = PBMTrackingEventRequest;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_Impression"]) {
        event = PBMTrackingEventImpression;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_Click"]) {
        event = PBMTrackingEventClick;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_OverlayClick"]) {
        event = PBMTrackingEventOverlayClick;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_CompanionClick"]) {
        event = PBMTrackingEventCompanionClick;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_Play"]) {
        event = PBMTrackingEventPlay;
    } else if ([description isEqualToString:@"pause"]) {
        event = PBMTrackingEventPause;
    } else if ([description isEqualToString:@"rewind"]) {
        event = PBMTrackingEventRewind;
    } else if ([description isEqualToString:@"resume"]) {
        event = PBMTrackingEventResume;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_Skip"]) {
        event = PBMTrackingEventSkip;
    } else if ([description isEqualToString:@"creativeView"]) {
        event = PBMTrackingEventCreativeView;
    } else if ([description isEqualToString:@"start"]) {
        event = PBMTrackingEventStart;
    } else if ([description isEqualToString:@"firstquartile"]) {
        event = PBMTrackingEventFirstQuartile;
    } else if ([description isEqualToString:@"midpoint"]) {
        event = PBMTrackingEventMidpoint;
    } else if ([description isEqualToString:@"thirdquartile"]) {
        event = PBMTrackingEventThirdQuartile;
    } else if ([description isEqualToString:@"complete"]) {
        event = PBMTrackingEventComplete;
    } else if ([description isEqualToString:@"mute"]) {
        event = PBMTrackingEventMute;
    } else if ([description isEqualToString:@"unmute"]) {
        event = PBMTrackingEventUnmute;
    } else if ([description isEqualToString:@"fullscreen"]) {
        event = PBMTrackingEventFullscreen;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_ExitFullscreen"]) {
        event = PBMTrackingEventExitFullscreen;
    } else if ([description isEqualToString:@"normal"]) {
        event = PBMTrackingEventNormal;
    } else if ([description isEqualToString:@"expand"]) {
        event = PBMTrackingEventExpand;
    } else if ([description isEqualToString:@"collapse"]) {
        event = PBMTrackingEventCollapse;
    } else if ([description isEqualToString:@"close"]) {
        event = PBMTrackingEventCloseLinear;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_CloseOverlay"]) {
        event = PBMTrackingEventCloseOverlay;
    } else if ([description isEqualToString:@"creativeModelTrackingKey_Error"]) {
        event = PBMTrackingEventError;
    } else if ([description isEqualToString:@"acceptInvitation"]) {
        event = PBMTrackingEventAcceptInvitation;
    } else if ([description isEqualToString:@"loaded"]) {
        event = PBMTrackingEventLoaded;
    } else if ([description isEqualToString:@"prebid_Win"]) {
        event = PBMTrackingEventPrebidWin;
    } else {
        event = PBMTrackingEventUnknown;
    }

    return event;
}

@end

//
//  OXMTrackingEvent.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTrackingEvent.h"

@implementation OXMTrackingEventDescription

+ (NSString *)getDescription:(OXMTrackingEvent)event {
    switch (event) {
        case OXMTrackingEventRequest            : return @"creativeModelTrackingKey_Request";
        case OXMTrackingEventImpression         : return @"creativeModelTrackingKey_Impression";
        case OXMTrackingEventClick              : return @"creativeModelTrackingKey_Click";
        case OXMTrackingEventOverlayClick       : return @"creativeModelTrackingKey_OverlayClick";
        case OXMTrackingEventCompanionClick     : return @"creativeModelTrackingKey_CompanionClick";
        case OXMTrackingEventPlay               : return @"creativeModelTrackingKey_Play";
        case OXMTrackingEventPause              : return @"pause";
        case OXMTrackingEventRewind             : return @"rewind";
        case OXMTrackingEventResume             : return @"resume";
        case OXMTrackingEventSkip               : return @"creativeModelTrackingKey_Skip";
        case OXMTrackingEventCreativeView       : return @"creativeView";
        case OXMTrackingEventStart              : return @"start";
        case OXMTrackingEventFirstQuartile      : return @"firstQuartile";
        case OXMTrackingEventMidpoint           : return @"midpoint";
        case OXMTrackingEventThirdQuartile      : return @"thirdQuartile";
        case OXMTrackingEventComplete           : return @"complete";
        case OXMTrackingEventMute               : return @"mute";
        case OXMTrackingEventUnmute             : return @"unmute";
        case OXMTrackingEventFullscreen         : return @"fullscreen";
        case OXMTrackingEventExitFullscreen     : return @"creativeModelTrackingKey_ExitFullscreen";
        case OXMTrackingEventNormal             : return @"normal";
        case OXMTrackingEventExpand             : return @"expand";
        case OXMTrackingEventCollapse           : return @"collapse";
        case OXMTrackingEventCloseLinear        : return @"close";
        case OXMTrackingEventCloseOverlay       : return @"creativeModelTrackingKey_CloseOverlay";
        case OXMTrackingEventError              : return @"creativeModelTrackingKey_Error";
        case OXMTrackingEventAcceptInvitation   : return @"acceptInvitation";
        case OXMTrackingEventLoaded             : return @"loaded";
    }
}

@end

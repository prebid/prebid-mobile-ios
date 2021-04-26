//
//  PBMTrackingEvent.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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
    }
}

@end

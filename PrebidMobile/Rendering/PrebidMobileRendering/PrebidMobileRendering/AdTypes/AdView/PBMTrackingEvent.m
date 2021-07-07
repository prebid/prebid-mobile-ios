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
    }
}

@end

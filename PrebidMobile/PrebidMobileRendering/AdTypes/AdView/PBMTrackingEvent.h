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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PBMTrackingEvent) {
    PBMTrackingEventRequest = 0,
    PBMTrackingEventImpression,
    PBMTrackingEventClick,
    PBMTrackingEventOverlayClick,
    PBMTrackingEventCompanionClick, // split these or no?
    
    PBMTrackingEventPlay,
    PBMTrackingEventPause,
    PBMTrackingEventResume,
    PBMTrackingEventRewind,
    PBMTrackingEventSkip,
    
    PBMTrackingEventCreativeView,
    PBMTrackingEventStart,
    PBMTrackingEventFirstQuartile,
    PBMTrackingEventMidpoint,
    PBMTrackingEventThirdQuartile,
    PBMTrackingEventComplete,
    
    PBMTrackingEventMute,
    PBMTrackingEventUnmute,
    
    PBMTrackingEventFullscreen,
    PBMTrackingEventExitFullscreen,
    PBMTrackingEventNormal,
    PBMTrackingEventExpand,
    PBMTrackingEventCollapse,
    
    PBMTrackingEventCloseLinear,
    PBMTrackingEventCloseOverlay,
    
    PBMTrackingEventAcceptInvitation,
    
    PBMTrackingEventError,
    
    PBMTrackingEventLoaded,
    
    PBMTrackingEventPrebidWin
};


NS_ASSUME_NONNULL_BEGIN
@interface PBMTrackingEventDescription : NSObject

+ (NSString *)getDescription:(PBMTrackingEvent)event;

@end
NS_ASSUME_NONNULL_END

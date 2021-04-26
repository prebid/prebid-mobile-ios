//
//  PBMTrackingEvent.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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
};


NS_ASSUME_NONNULL_BEGIN
@interface PBMTrackingEventDescription : NSObject

+ (NSString *)getDescription:(PBMTrackingEvent)event;

@end
NS_ASSUME_NONNULL_END

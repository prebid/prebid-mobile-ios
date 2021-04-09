//
//  OXMTrackingEvent.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OXMTrackingEvent) {
    OXMTrackingEventRequest = 0,
    OXMTrackingEventImpression,
    OXMTrackingEventClick,
    OXMTrackingEventOverlayClick,
    OXMTrackingEventCompanionClick, // split these or no?
    
    OXMTrackingEventPlay,
    OXMTrackingEventPause,
    OXMTrackingEventResume,
    OXMTrackingEventRewind,
    OXMTrackingEventSkip,
    
    OXMTrackingEventCreativeView,
    OXMTrackingEventStart,
    OXMTrackingEventFirstQuartile,
    OXMTrackingEventMidpoint,
    OXMTrackingEventThirdQuartile,
    OXMTrackingEventComplete,
    
    OXMTrackingEventMute,
    OXMTrackingEventUnmute,
    
    OXMTrackingEventFullscreen,
    OXMTrackingEventExitFullscreen,
    OXMTrackingEventNormal,
    OXMTrackingEventExpand,
    OXMTrackingEventCollapse,
    
    OXMTrackingEventCloseLinear,
    OXMTrackingEventCloseOverlay,
    
    OXMTrackingEventAcceptInvitation,
    
    OXMTrackingEventError,
    
    OXMTrackingEventLoaded,
};


NS_ASSUME_NONNULL_BEGIN
@interface OXMTrackingEventDescription : NSObject

+ (NSString *)getDescription:(OXMTrackingEvent)event;

@end
NS_ASSUME_NONNULL_END

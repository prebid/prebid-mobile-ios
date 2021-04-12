//
//  OXMEventTrackerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMTrackingEvent.h"

@class OXMVideoVerificationParameters;

/**
     This protocol defines methods for tracking ad's lifesycle.
 
     This protocol declares methods that needed for ad tracking in OpenXSDK. For now, we have two implementations:
     - OXMAdModelEventTracker
     - OXMOpenMeasurementEventTracker
 */
@protocol OXMEventTrackerProtocol <NSObject>

- (void)trackEvent:(OXMTrackingEvent)event;

- (void)trackVideoAdLoaded:(OXMVideoVerificationParameters *)parameters;
- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume;
- (void)trackVolumeChanged:(CGFloat)playerVolume deviceVolume:(CGFloat)deviceVolume;

@end

//
//  PBMEventTrackerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMTrackingEvent.h"

@class PBMVideoVerificationParameters;

/**
     This protocol defines methods for tracking ad's lifesycle.
 
     This protocol declares methods that needed for ad tracking in PrebidMobileRendering. For now, we have two implementations:
     - PBMAdModelEventTracker
     - PBMOpenMeasurementEventTracker
 */
@protocol PBMEventTrackerProtocol <NSObject>

- (void)trackEvent:(PBMTrackingEvent)event;

- (void)trackVideoAdLoaded:(PBMVideoVerificationParameters *)parameters;
- (void)trackStartVideoWithDuration:(CGFloat)duration volume:(CGFloat)volume;
- (void)trackVolumeChanged:(CGFloat)playerVolume deviceVolume:(CGFloat)deviceVolume;

@end

//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

/**
     This protocol defines methods for tracking ad's lifesycle.
 
     This protocol declares methods that needed for ad tracking in PrebidMobile. For now, we have two implementations:
     - AdModelEventTracker
     - PBMOpenMeasurementEventTracker
 */
@objc(PBMEventTrackerProtocol)
public protocol EventTrackerProtocol {
    
    func trackEvent(_ event: TrackingEvent)
    
    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters)
    func trackStartVideo(duration: TimeInterval, volume: Double)
    
    @objc(trackVolumeChanged:deviceVolume:)
    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double)
    
}

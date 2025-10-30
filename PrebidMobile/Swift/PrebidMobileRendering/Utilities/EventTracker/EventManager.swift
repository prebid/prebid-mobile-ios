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

import UIKit

/**
    This class is a proxy container for event trackers.
    You can add (and remove) any quantity of trackers.
    Each tracker must correspond to EventTrackerProtocol the EventTracker Protocol.
 
    EventManager implements EventTrackerProtocol.
    It broadcasts protocol calls to the all registered trackers.
 */
@objc(PBMEventManager) @objcMembers
public class EventManager: NSObject, EventTrackerProtocol {
    
    // MARK: - Internal properties
    
    private var trackers = [EventTrackerProtocol]()
    
    // MARK: - Public Methods
    
    public func registerTracker(_ tracker: EventTrackerProtocol) {
        if trackers.contains(where: { $0 === tracker }) {
            return
        }
        
        trackers.append(tracker)
    }
    
    public func unregisterTracker(_ tracker: EventTrackerProtocol) {
        trackers = trackers.filter({ $0 !== tracker })
    }
    
    public func unregisterAllTrackers() {
        trackers.removeAll()
    }
    
    // MARK: - EventTrackerProtocol
    
    public func trackEvent(_ event: TrackingEvent) {
        trackers.forEach { $0.trackEvent(event) }
    }
    
    public func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {
        trackers.forEach { $0.trackVideoAdLoaded(parameters) }
    }
    
    public func trackStartVideo(duration: TimeInterval, volume: Double) {
        trackers.forEach { $0.trackStartVideo(duration: duration, volume: volume) }
    }
    
    public func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {
        trackers.forEach { $0.trackVolumeChanged(playerVolume: playerVolume, deviceVolume: deviceVolume) }
    }
}

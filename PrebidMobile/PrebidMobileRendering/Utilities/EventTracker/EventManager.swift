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
    Each tracker must correspond to PBMEventTrackerProtocol the PBMEventTracker Protocol.
 
    EventManager implements PBMEventTrackerProtocol.
    It broadcasts protocol calls to the all registered trackers.
 */
@objc(PBMEventManager) @objcMembers
public class EventManager: NSObject, PBMEventTrackerProtocol {
    
    // MARK: - Internal properties
    
    private var trackers = [PBMEventTrackerProtocol]()
    
    // MARK: - Public Methods
    
    public func registerTracker(_ tracker: PBMEventTrackerProtocol) {
        if trackers.contains(where: { $0 === tracker }) {
            return
        }
        
        trackers.append(tracker)
    }
    
    public func unregisterTracker(_ tracker: PBMEventTrackerProtocol) {
        trackers = trackers.filter({ $0 !== tracker })
    }
    
    // MARK: - PBMEventTrackerProtocol
    
    public func trackEvent(_ event: PBMTrackingEvent) {
        trackers.forEach { $0.trackEvent(event) }
    }
    
    public func trackVideoAdLoaded(_ parameters: PBMVideoVerificationParameters!) {
        trackers.forEach { $0.trackVideoAdLoaded(parameters) }
    }
    
    public func trackStartVideo(withDuration duration: CGFloat, volume: CGFloat) {
        trackers.forEach { $0.trackStartVideo(withDuration: duration, volume: volume) }
    }
    
    public func trackVolumeChanged(_ playerVolume: CGFloat, deviceVolume: CGFloat) {
        trackers.forEach { $0.trackVolumeChanged(playerVolume, deviceVolume: deviceVolume) }
    }
}

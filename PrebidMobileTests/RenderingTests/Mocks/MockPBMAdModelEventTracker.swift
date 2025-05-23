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

import Foundation

@testable @_spi(PBMInternal) import PrebidMobile

class MockPBMAdModelEventTracker: AdModelEventTracker {
    
    var mock_trackEvent: ((TrackingEvent) -> Void)?
    override func trackEvent(_ event: TrackingEvent) {
        mock_trackEvent?(event)
    }
    
    var mock_trackVideoAdLoaded: ((VideoVerificationParameters) -> Void)?
    override func trackVideoAdLoaded(_ parameters: VideoVerificationParameters)  {
        mock_trackVideoAdLoaded?(parameters)
    }
    
    var mock_trackStartVideo: ((TimeInterval, Double) -> Void)?
    override func trackStartVideo(duration: TimeInterval, volume: Double) {
        mock_trackStartVideo?(duration, volume)
    }
    
    var mock_trackVolumeChanged: ((Double, Double) -> Void)?
    override func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {
        mock_trackVolumeChanged?(playerVolume, deviceVolume)
    }
}

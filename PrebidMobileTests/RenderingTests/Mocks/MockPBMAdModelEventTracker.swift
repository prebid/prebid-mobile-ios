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

@testable import PrebidMobile

class MockPBMAdModelEventTracker: PBMAdModelEventTracker {
    
    var mock_trackEvent: ((PBMTrackingEvent) -> Void)?
    override func trackEvent(_ event: PBMTrackingEvent) {
        mock_trackEvent?(event)
    }
    
    var mock_trackVideoAdLoaded: ((PBMVideoVerificationParameters) -> Void)?
    override func trackVideoAdLoaded(_ parameters: PBMVideoVerificationParameters)  {
        mock_trackVideoAdLoaded?(parameters)
    }
    
    var mock_trackStartVideo: ((CGFloat, CGFloat) -> Void)?
    override func trackStartVideo(withDuration: CGFloat, volume:CGFloat) {
        mock_trackStartVideo?(withDuration, volume)
    }
    
    var mock_trackVolumeChanged: ((CGFloat, CGFloat) -> Void)?
    override func trackVolumeChanged(_ playerVolume: CGFloat, deviceVolume: CGFloat) {
        mock_trackVolumeChanged?(playerVolume, deviceVolume)
    }
}

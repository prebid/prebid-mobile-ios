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

import XCTest
@testable import PrebidMobile

class VideoControlsConfigTests: XCTestCase {
    func testDefaultIsMuted() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertTrue(adConfiguration.isMuted == false)
    }

    func testDefaultIsMuteControlsDisabled() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertTrue(adConfiguration.isSoundButtonVisible == false)
    }

    func testCloseButtonArea() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertEqual(adConfiguration.closeButtonArea, PBMConstants.BUTTON_AREA_DEFAULT.doubleValue)
    }
    
    func testDefaultCloseButtonPosition() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertTrue(adConfiguration.closeButtonPosition == .topRight)
    }
    
    func testDefaultSkipButtonArea() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertEqual(adConfiguration.skipButtonArea, PBMConstants.BUTTON_AREA_DEFAULT.doubleValue)
    }
    
    func testDefaultSkipButtonPosition() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertEqual(adConfiguration.skipButtonPosition, .topLeft)
    }
    
    func testDefaultSkipButtonDelay() {
        let adConfiguration = VideoControlsConfiguration()
        XCTAssertEqual(adConfiguration.skipDelay, PBMConstants.SKIP_DELAY_DEFAULT.doubleValue)
    }
    
    func testInitWithORTBAdConfiguration() {
        let adConfiguration = VideoControlsConfiguration()
        
        let ortbAdConfig = PBMORTBAdConfiguration()
        ortbAdConfig.isMuted = false
        ortbAdConfig.maxVideoDuration = 40
        ortbAdConfig.skipButtonArea = 0.3
        ortbAdConfig.skipButtonPosition = "topleft"
        ortbAdConfig.closeButtonArea = 0.3
        ortbAdConfig.closeButtonPosition = "topleft"
        
        adConfiguration.initialize(with: ortbAdConfig)
        
        XCTAssertEqual(adConfiguration.isMuted, false)
        XCTAssertEqual(adConfiguration.maxVideoDuration?.doubleValue, 40)
        XCTAssertEqual(adConfiguration.skipButtonArea, 0.3)
        XCTAssertEqual(adConfiguration.skipButtonPosition, .topLeft)
        XCTAssertEqual(adConfiguration.closeButtonArea, 0.3)
        XCTAssertEqual(adConfiguration.closeButtonPosition, .topLeft)
        
    }
}

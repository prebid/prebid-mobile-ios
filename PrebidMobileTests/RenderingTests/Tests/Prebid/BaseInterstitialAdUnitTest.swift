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

class BaseInterstitialAdUnitTest: XCTestCase {

    func testCloseButtonArea() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        let videoConfig = adUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = 1.1
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = -0.1
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = 0.25
        XCTAssertTrue(videoConfig.closeButtonArea == 0.25)
    }
    
    func testCloseButtonPosition() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        let videoConfig = adUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertEqual(videoConfig.closeButtonPosition, .topRight)
        
        videoConfig.closeButtonPosition = .topLeft
        XCTAssertEqual(videoConfig.closeButtonPosition, .topLeft)
    }
}

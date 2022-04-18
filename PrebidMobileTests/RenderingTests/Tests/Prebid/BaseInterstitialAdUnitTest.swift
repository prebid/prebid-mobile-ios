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
import PrebidMobile

class BaseInterstitialAdUnitTest: XCTestCase {

    func testCloseButtonArea() {
        let adUnit = BaseInterstitialAdUnit(configID: "test")
        XCTAssertTrue(adUnit.closeButtonArea == 0.1)
        
        adUnit.closeButtonArea = 1.1
        XCTAssertTrue(adUnit.closeButtonArea == 0.1)
        
        adUnit.closeButtonArea = -0.1
        XCTAssertTrue(adUnit.closeButtonArea == 0.1)
        
        adUnit.closeButtonArea = 0.25
        XCTAssertTrue(adUnit.closeButtonArea == 0.25)
    }
    
    func testCloseButtonPosition() {
        let adUnit = BaseInterstitialAdUnit(configID: "test")
        XCTAssertEqual(adUnit.closeButtonPosition, .topRight)
        
        adUnit.closeButtonPosition = .topLeft
        XCTAssertEqual(adUnit.adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition, .topLeft)
    }
}

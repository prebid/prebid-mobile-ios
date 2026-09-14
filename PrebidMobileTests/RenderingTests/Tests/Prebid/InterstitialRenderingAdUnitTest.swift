/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

class InterstitialRenderingAdUnitTest: XCTestCase {
    
    func testSetAdPosition() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        
        let adUnitConfig = adUnit.adUnitConfig
        
        adUnit.adPosition = .header
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .header)
        
        adUnit.adPosition = .footer
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .footer)
    }
    
    func testAdFormats() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        let adUnitConfig = adUnit.adUnitConfig
        
        // Default: multiformat
        XCTAssertEqual(adUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // Single format
        adUnit.adFormats = [.video]
        XCTAssertEqual(adUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
        
        adUnit.adFormats = [.banner]
        XCTAssertEqual(adUnit.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Back to multiformat
        adUnit.adFormats = [.banner, .video]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    func testAdFormatsRejectsEmptySet() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        let adUnitConfig = adUnit.adUnitConfig
        
        adUnit.adFormats = [.video]
        
        adUnit.adFormats = []
        
        XCTAssertEqual(adUnit.adFormats, [.video], "Empty set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
    }
    
    func testAdFormatsRejectsUnsupportedFormats() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        let adUnitConfig = adUnit.adUnitConfig
        
        // Unsupported only
        adUnit.adFormats = [.native]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video], "Native-only set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // Mixed supported + unsupported must be rejected as a whole
        adUnit.adFormats = [.video, .native]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video], "Set containing native must be ignored entirely")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // A valid set is still accepted afterwards
        adUnit.adFormats = [.video]
        XCTAssertEqual(adUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
    }
}

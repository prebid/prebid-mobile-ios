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

class PBMAdUnitConfigTest: XCTestCase {
    
    let adUnitConfig = AdUnitConfig(configId: "dummy-config-id")
    
    func testSetRefreshInterval() {
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }
    
    func testRefreshIntervalIsNotResetByAdFormats() {
        adUnitConfig.refreshInterval = 30
        
        adUnitConfig.adFormats = [.banner, .video]
        XCTAssertEqual(adUnitConfig.refreshInterval, 30, "Changing adFormats must not discard a configured interval")
        
        adUnitConfig.adFormats = [.video]
        XCTAssertEqual(adUnitConfig.refreshInterval, 30)
        
        adUnitConfig.adFormats = [.banner]
        XCTAssertEqual(adUnitConfig.refreshInterval, 30)
    }
    
    func testRefreshIntervalIsIndependentOfWinningBidFormat() {
        adUnitConfig.adConfiguration.winningBidAdFormat = .video
        
        adUnitConfig.refreshInterval = 45
        XCTAssertEqual(adUnitConfig.refreshInterval, 45, "refreshInterval is publisher configuration, not render state")
        
        adUnitConfig.adConfiguration.winningBidAdFormat = .banner
        XCTAssertEqual(adUnitConfig.refreshInterval, 45)
    }
    
    // MARK: - The Prebid Ad Slot
    
    func testSetPbAdSlot() {        
        XCTAssertNil(adUnitConfig.getPbAdSlot())
        adUnitConfig.setPbAdSlot("test-ad-slot")
        XCTAssertEqual("test-ad-slot", adUnitConfig.getPbAdSlot())
    }
}

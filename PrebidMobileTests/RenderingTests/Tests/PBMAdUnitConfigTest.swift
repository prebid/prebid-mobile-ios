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
    
    func testIsNativeAd() {
        let adUnitConfig = AdUnitConfig(configID: "dummy-config-id")
        XCTAssertFalse(adUnitConfig.adConfiguration.isNative)
        
        let nativeAdConfig = NativeAdConfiguration(assets: [PBRNativeAssetTitle(length: 25)])
        adUnitConfig.nativeAdConfiguration = nativeAdConfig
        XCTAssertTrue(adUnitConfig.adConfiguration.isNative)
    }
    
    func testSetRefreshInterval() {
        let adUnitConfig = AdUnitConfig(configID: "dummy-config-id")
        
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }
}

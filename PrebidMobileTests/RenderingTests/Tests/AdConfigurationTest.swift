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

class AdConfigurationTest: XCTestCase {
    
    func testIsInterstitialDisablesAutoRefresh() {
        let adConfiguration = AdConfiguration()
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)
        
        // Setting an auto refresh value for an interstitial should always result in `nil`.
        adConfiguration.isInterstitialAd = true
        adConfiguration.autoRefreshDelay = 1
        XCTAssertNil(adConfiguration.autoRefreshDelay)
        
        // Setting an interstitial back to false, should re-enable auto refresh. Admittedly, this
        // may be unnecessary.
        adConfiguration.isInterstitialAd = false
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)
        
        // Expect the same effect from `forceInterstitialPresentation`
        adConfiguration.forceInterstitialPresentation = true
        XCTAssertNil(adConfiguration.autoRefreshDelay)
        adConfiguration.forceInterstitialPresentation = nil
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)
    }
}

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
import GoogleMobileAds
@testable import PrebidMobile

final class PrebidGMASDKTests: XCTestCase {
    
    var loggerHelper: LoggerHelper?
    
    override func tearDown() {
        super.tearDown()
        
        loggerHelper = nil
    }
    
    func testGMAVersion() {
        loggerHelper = .init()
        
        let currentGMASDKVersion = GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)
        PrebidSDKInitializer.checkGMAVersion(gadVersion: currentGMASDKVersion)
        
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssertTrue(log.isEmpty, "The current version of Prebid SDK is not validated with the latest version of GMA SDK.")
    }
}

/*   Copyright 2018-2025 Prebid.org, Inc.
 
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

// NOTE: Starting with v12, the GMA SDK has introduced new naming conventions for its classes.

final class GMAApiAvailabilityTests: XCTestCase {

    func testAvailability_GAMRequest() {
        let request = AdManagerRequest()
        let adObject = request as AnyObject
        let adObjectString = String(describing: type(of: adObject))
        
        XCTAssertEqual(adObjectString, .GAM_Object_Name)
        XCTAssertTrue(adObject.responds(to: NSSelectorFromString("setCustomTargeting:")))
    }
    
    func testAvailability_GADRequest() {
        let request = Request()
        let adObject = request as AnyObject
        let adObjectString = String(describing: type(of: adObject))
        
        XCTAssertEqual(adObjectString, .GAD_Object_Name)
        XCTAssertTrue(adObject.responds(to: NSSelectorFromString("setCustomTargeting:")))
    }
    
    func testAvailability_GADCustomNativeAd() {
        let ad = CustomNativeAd()
        let adObject = ad as AnyObject
        let adObjectString = String(describing: type(of: adObject))
        
        XCTAssertEqual(adObjectString, .GAD_Object_Custom_Native_Name)
    }
}

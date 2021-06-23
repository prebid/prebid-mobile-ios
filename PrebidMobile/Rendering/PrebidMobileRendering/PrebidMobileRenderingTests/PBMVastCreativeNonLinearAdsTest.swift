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

class PBMVastCreativeNonLinearAdsTest: XCTestCase {
    
    // Verify PBMVastCreativeNonLinearAds.copyTracking() copies over the correct number of URIs
    func testCopyTracking() {
        
        let ad1 = PBMVastCreativeNonLinearAds()
        ad1.id = "111111"
        
        let nonLinear1 = PBMVastCreativeNonLinearAdsNonLinear()
        nonLinear1.clickThroughURI = "URI_1"
        nonLinear1.clickTrackingURIs = ["URI_1a", "URI_1b"]
        ad1.nonLinears.add(nonLinear1)
        
        let ad2 = PBMVastCreativeNonLinearAds()
        ad2.id = "222222"
        
        let nonLinear2 = PBMVastCreativeNonLinearAdsNonLinear()
        nonLinear2.clickThroughURI = "URI_2"
        nonLinear2.clickTrackingURIs = ["URI_2a", "URI_2b"]
        ad2.nonLinears.add(nonLinear2)
        
        // precondition: should contain only 2
        var nonLinear = ad1.nonLinears[0] as! PBMVastCreativeNonLinearAdsNonLinear
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1b"))
        XCTAssert(nonLinear.clickTrackingURIs.count == 2)
        
        ad1.copyTracking(fromNonLinearAds: ad2)
        
        // URIs in ad1 should contain all 4 URIs: "URI_1a", "URI_1b", "URI_2a", "URI_2b"
        
        nonLinear = ad1.nonLinears[0] as! PBMVastCreativeNonLinearAdsNonLinear
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1b"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_2a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_2b"))
        XCTAssert(nonLinear.clickTrackingURIs.count == 4)
    }
    
}

//
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

class PBMVastLoaderTestOMVerificationInExtension: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    override func setUp() {
        self.continueAfterFailure = true
    }
    
    override func tearDown() {
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {
        
        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        //Make an PrebidServerConnection and redirect its network requests to the Mock Server
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Make an AdConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.requestCompletedSuccess(vastResponse: response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("vast_om_verification_from_extension.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func requestCompletedSuccess(vastResponse: PBMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        PBMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? PBMVastInlineAd else {
            XCTFail()
            return;
        }
        
        XCTAssertNotNil(ad.verificationParameters)
        XCTAssertEqual(ad.verificationParameters.verificationResources.count, 1)
        
        let resource1 = ad.verificationParameters.verificationResources[0] as! PBMVideoVerificationResource
        PBMAssertEq(resource1.url, "https://company.com/omid.js")
        PBMAssertEq(resource1.vendorKey, "company.com-omid")
        PBMAssertEq(resource1.params, "parameter1=value1&parameter2=value2&parameter3=value3")
        PBMAssertEq(resource1.apiFramework, "omid")
        
        XCTAssertNotNil(resource1.trackingEvents)
        XCTAssertNotNil(resource1.trackingEvents?.trackingEvents)
        
        let trackingEvents = resource1.trackingEvents?.trackingEvents
        
        XCTAssertEqual(trackingEvents?["verificationNotExecuted"], ["https://company.com/pixel.jpg?error=[REASON]"])
        
        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}

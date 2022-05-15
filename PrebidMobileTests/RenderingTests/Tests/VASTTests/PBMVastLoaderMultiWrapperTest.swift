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

import Foundation
import XCTest
@testable import PrebidMobile

class PBMVastLoaderMultiWrapperTest: XCTestCase {
    
    var vastRequestFailureExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
    }
    
    func testVastTooManyWrappers () {
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        MockServer.shared.resetRules([
            MockServerRule(urlNeedle: "http://foo.com/", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_wrapper_ad.xml")
        ])
        
        self.vastRequestFailureExpectation = self.expectation(description: "Expected VAST Load to be failure")
        
        conn.protocolClasses.append(MockServerURLProtocol.self)
        
        //Make an AdConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            XCTFail("Request must be failure")
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTAssertTrue(error.localizedDescription.contains("Wrapper limit reached"))
            self.vastRequestFailureExpectation.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
}

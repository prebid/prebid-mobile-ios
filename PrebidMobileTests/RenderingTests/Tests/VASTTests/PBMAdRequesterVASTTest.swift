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

class PBMAdRequesterVASTTest: XCTestCase {
    
    var successfulExpectation:XCTestExpectation?
    var failedExpectation:XCTestExpectation?
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    override func setUp() {
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.successfulExpectation = nil
        self.failedExpectation = nil
    }
    
    func testSuccess() {
        self.successfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        vastServerResponse = nil
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        let ruleInline =  MockServerRule(urlNeedle: "foo.com/inline/vast", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_inline_ad.xml")
        
        MockServer.shared.resetRules([ruleInline])
        
        let adConfiguration = AdConfiguration()
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml")  {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
    }
    
    func testFailed() {
        
        self.failedExpectation = self.expectation(description: "Expected VAST Load to be failed")
        vastServerResponse = nil
        
        let conn = PrebidServerConnection()
        let adConfiguration = AdConfiguration()
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_Empty_Response.xml")  {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNil(vastServerResponse)
    }
    
    func testVastLoaderFacade () {
        //Make an AdConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        self.successfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("inline_with_padding_on_urls.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(self.vastServerResponse)
        if self.vastServerResponse == nil {
            return
        }
        
        let vastRequestErrorExpectation = self.expectation(description: "Expected wrapper limit")
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerResponse!,
                              successCallback: { models in
            XCTAssertEqual(models.count, 1)
            let model = models.first! as PBMCreativeModel
            XCTAssert(model.videoFileURL == "http://i.cdn.openx.com/videos/mobile/OpenX_15_Seconds_Fade_Small.mp4")
            vastRequestErrorExpectation.fulfill()
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
            vastRequestErrorExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 3)
    }
    
    func testRequestWithMaxDuration() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        adConfiguration.videoParameters.maxDuration = SingleContainerInt(integerLiteral: 1)
                
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("inline_with_padding_on_urls.xml") {
            requester.buildAdsArray(data)
        }
        
        XCTAssertNotNil(self.vastServerResponse)
        if self.vastServerResponse == nil {
            return
        }
        
        let vastRequestErrorExpectation = self.expectation(description: "Expected fail due to video duration value that is bigger than max value set in adConfiguration.")
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerResponse!,
                              successCallback: { models in
           XCTFail()
        },
                              failureCallback: { error in
            vastRequestErrorExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 3)
    }
}

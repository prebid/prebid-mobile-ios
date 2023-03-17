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

class CreativeModelCollectionMakerVASTTests: XCTestCase {
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    var successfulExpectation: XCTestExpectation?
    
    override func tearDown() {
        successfulExpectation = nil
    }
    
    func testMakeCompanionAd() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        successfulExpectation = expectation(description: "Expected VAST Load to be successful")
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_companion.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        let successCallbackExpectation = expectation(description: "makeModels successCallback called")
        
        modelMaker.makeModels(vastServerResponse!,
                              successCallback: { models in
            successCallbackExpectation.fulfill()
            
            XCTAssertEqual(models.count, 2)
            XCTAssertTrue(models[0].hasCompanionAd)
            XCTAssertFalse(models[0].isCompanionAd)
            XCTAssertFalse(models[1].hasCompanionAd)
            XCTAssertTrue(models[1].isCompanionAd)
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testMakeCompanionAd_empty() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        successfulExpectation = expectation(description: "Expected VAST Load to be successful")
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_empty_companion.xml") {
            requester.buildAdsArray(data)
        }
        
        waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        let successCallbackExpectation = expectation(description: "makeModels successCallback called")
        
        modelMaker.makeModels(vastServerResponse!,
                              successCallback: { models in
            XCTAssertEqual(models.count, 1)
            XCTAssertFalse(models.first!.hasCompanionAd)
            XCTAssertFalse(models.first!.isCompanionAd)
            successCallbackExpectation.fulfill()
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
        })
        
        waitForExpectations(timeout: 3)
    }
}

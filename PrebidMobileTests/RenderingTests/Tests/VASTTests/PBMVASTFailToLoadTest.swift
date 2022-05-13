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

class PBMVASTFailToLoadTest: XCTestCase, PBMAdLoadManagerDelegate {
    
    var failedToLoadAdExpectation:XCTestExpectation?
    
    func testAdLoadManagerVastEmptyResponse() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Response.xml")
    }
    
    func testAdLoadManagerVastEmptyResponse2() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Response2.xml")
    }
    
    func testAdLoadManagerVastEmptyVideoAd() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Inline.xml")
    }
    
    func loadAdLoadManager(file: String) {
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let adLoadManager = PBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection: conn, adConfiguration: AdConfiguration())
        adLoadManager.adLoadManagerDelegate = self
        adLoadManager.adConfiguration = adConfiguration
        
        if let string = UtilitiesForTesting.loadFileAsStringFromBundle(file) {
            adLoadManager.load(from: string)
        }
        
        self.waitForExpectations(timeout: 2)
    }
    
    //MARK: PBMAdLoadManagerDelegate
    
    func loadManager(_ loadManager: PBMAdLoadManagerProtocol, didLoad transaction: PBMTransaction) {
        XCTFail()
    }
    
    func loadManager(_ loadManager: PBMAdLoadManagerProtocol, failedToLoad transaction: PBMTransaction?, error: Error) {
        failedToLoadAdExpectation?.fulfill()
    }
}

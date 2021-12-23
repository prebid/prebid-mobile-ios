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

class MediationNativeAdUnitTest: XCTestCase, WinningBidResponseFabricator {
    let configID = "testConfigID"
    let nativeAdConfig = NativeAdConfiguration(assets: [PBRNativeAssetTitle(length: 25)])
    
    var adObject: MockAdObject?
    var mediationDelegate: PrebidMediationDelegate?
    
    override func setUp() {
        super.setUp()
        
        adObject = MockAdObject()
        mediationDelegate = MockMediationUtils(adObject: adObject!)
    }
    
    func testFetch() {
        let markupString = """
{"assets": [{"required": 1, "title": { "text": "OpenX (Title)" }}],
"link": {"url": "http://www.openx.com"}}
"""
        let bidPrice = 0.42
        let bidResponse = makeWinningBidResponse(bidPrice: bidPrice)
        
        let adUnit = NativeAdUnit(configID: configID,
                                  nativeAdConfiguration: nativeAdConfig) { adUnitConfig in
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    responseHandler(bidResponse, nil)
                },
            ])
        } winNotifierBlock: { _, adMarkupStringHandler in
            adMarkupStringHandler(markupString)
        }
        
        let mockAdUnit = MediationNativeAdUnit(nativeAdUnit: adUnit, mediationDelegate: mediationDelegate!)
        
        let fetchExpectation = expectation(description: "fetchDemand executed")
        
        mockAdUnit.fetchDemand(with: self.adObject!) { [weak self] result in
            XCTAssertEqual(result, .ok)
            PBMAssertEq(self!.adObject!.localExtras?[MockMediationAdUnitBidKey] as? DemandResponseInfo, adUnit.lastDemandResponseInfo)
            fetchExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.2)
    }
    
}

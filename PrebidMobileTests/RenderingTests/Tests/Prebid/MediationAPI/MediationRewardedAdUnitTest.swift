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

class MediationRewardedAdUnitTest: XCTestCase {
    
    let mediationDelegate: PrebidMediationDelegate = MockMediationUtils(adObject: MockAdObject())
    
    func testDefaultSettings() {
        let adUnit = MediationRewardedAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate)
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.adConfiguration.isInterstitialAd)
        XCTAssertTrue(adUnitConfig.adConfiguration.isRewarded)
        PBMAssertEq(adUnitConfig.adPosition, .fullScreen)
        XCTAssertTrue(adUnitConfig.adFormats.contains(.video))
    }

    func testFetchDemandBidInfoProvidesWinningBid() {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let sdkConfiguration = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        sdkConfiguration.prebidServerAccountId = Prebid.devintAccountID

        let adUnit = MediationRewardedAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate)

        let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")

        adUnit.fetchDemandBidInfo(connection: connection,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: Targeting.shared)
        { bidInfo in
            XCTAssertEqual(bidInfo.resultCode, .prebidDemandFetchSuccess)
            XCTAssertEqual(bidInfo.price?.doubleValue, 0.1091)
            XCTAssertEqual(bidInfo.creativeId, "test-creative-id-1")
            XCTAssertEqual(bidInfo.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31")

            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

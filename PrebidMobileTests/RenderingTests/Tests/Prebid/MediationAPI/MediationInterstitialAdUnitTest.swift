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

@_spi(PBMInternal) @testable import PrebidMobile

class MediationInterstitialAdUnitTest: XCTestCase {
    private let sdkConfiguration: Prebid = {
        let config = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        config.prebidServerAccountId = Prebid.devintAccountID
        return config
    }()
    private let targeting = Targeting.shared
    
    var adObject: MockAdObject?
    var mediationDelegate: PrebidMediationDelegate?
    
    override func setUp() {
        adObject = MockAdObject()
        mediationDelegate = MockMediationUtils(adObject: adObject!)
        super.setUp()
    }
    
    func testDefaultSettings() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", minSizePercentage: CGSize(width: 30, height: 30), mediationDelegate: mediationDelegate!)
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.adConfiguration.isInterstitialAd)
        PBMAssertEq(adUnitConfig.adPosition, .fullScreen)
    }
    
    func testAdFormats() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate!)
        let adUnitConfig = adUnit.adUnitConfig
        
        // Default: multiformat
        XCTAssertEqual(adUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // Single format
        adUnit.adFormats = [.video]
        XCTAssertEqual(adUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
        
        adUnit.adFormats = [.banner]
        XCTAssertEqual(adUnit.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Back to multiformat
        adUnit.adFormats = [.banner, .video]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    func testAdFormatsRejectsEmptySet() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate!)
        let adUnitConfig = adUnit.adUnitConfig
        
        adUnit.adFormats = [.video]
        
        adUnit.adFormats = []
        
        XCTAssertEqual(adUnit.adFormats, [.video], "Empty set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
    }
    
    func testAdFormatsRejectsUnsupportedFormats() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate!)
        let adUnitConfig = adUnit.adUnitConfig
        
        // Unsupported only
        adUnit.adFormats = [.native]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video], "Native-only set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // Mixed supported + unsupported must be rejected as a whole
        adUnit.adFormats = [.video, .native]
        XCTAssertEqual(adUnit.adFormats, [.banner, .video], "Set containing native must be ignored entirely")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
        
        // A valid set is still accepted afterwards
        adUnit.adFormats = [.video]
        XCTAssertEqual(adUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
    }
    
    func testAdObjectSetUpCleanUp() {
        //a good response with a bid
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let initialKeywords = "key1,key2"
        
        adObject!.keywords = initialKeywords
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MediationInterstitialAdUnit(configId: configId, minSizePercentage: CGSize(width: 30, height: 30), mediationDelegate: mediationDelegate!)
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { [weak self] result in
            XCTAssertEqual(result, .prebidDemandFetchSuccess)
            
            let resultKeywords = self!.adObject!.keywords!
            XCTAssertTrue(resultKeywords.contains("hb_pb:0.10"))
            
            let resultExtras: [AnyHashable : Any] = self!.adObject!.localExtras!
            XCTAssertEqual(resultExtras.count, 3)
            XCTAssertEqual(resultExtras[MockMediationConfigIdKey] as? String, configId)
            let bid = resultExtras[MockMediationAdUnitBidKey] as! NSObject
            XCTAssertTrue(bid.isKind(of: Bid.self))
            
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        
        //a bad response with the same ad object without bids
        
        let noBidConnection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.serverErrorResponse)
        }])
        
        let asyncExpectation2 = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: noBidConnection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { [weak self] result in
            XCTAssertEqual(result, .prebidServerError)
            
            let resultKeywords = self!.adObject!.keywords!
            XCTAssertEqual(resultKeywords, initialKeywords)
            let resultExtras: [AnyHashable : Any] = self!.adObject!.localExtras!
            XCTAssertEqual(resultExtras.count, 0)
            
            asyncExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: - fetchDemandBidInfo

    func testFetchDemandBidInfoProvidesWinningBid() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MediationInterstitialAdUnit(configId: configId, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        assertWinningBidEconomics(bidInfo)
        XCTAssertEqual(bidInfo?.targetingKeywords?["hb_pb"], "0.10")

        XCTAssertTrue(adObject!.keywords!.contains("hb_pb:0.10"))
        XCTAssertEqual(adObject!.localExtras?[MockMediationConfigIdKey] as? String, configId)
        XCTAssertTrue(adObject!.localExtras?[MockMediationAdUnitBidKey] is Bid)
    }

    func testFetchDemandBidInfoOnServerError() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.serverErrorResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidServerError)
        XCTAssertNil(bidInfo?.targetingKeywords)
        XCTAssertNil(bidInfo?.price)
        XCTAssertNil(bidInfo?.creativeId)
    }

    func testFetchDemandBidInfoWhenAdObjectSetUpFails() {
        let adUnit = MediationInterstitialAdUnit(configId: "prebidConfigId", mediationDelegate: MockRejectingMediationDelegate())

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        // Nothing was attached to the ad object, so only the request id is reported
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31")
        assertNoBidAttached(bidInfo)
    }

    private func fetchBidInfo(_ adUnit: MediationBaseInterstitialAdUnit, response: PrebidServerResponse) -> BidInfo? {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(response)
        }])

        let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")
        var result: BidInfo?

        adUnit.fetchDemandBidInfo(connection: connection,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting)
        { bidInfo in
            XCTAssertTrue(Thread.isMainThread)
            result = bidInfo
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        return result
    }

    private func assertWinningBidEconomics(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        // Values of `BidResponseTransformer.someValidResponse`
        XCTAssertEqual(bidInfo?.price?.doubleValue, 0.1091, file: file, line: line)
        XCTAssertEqual(bidInfo?.currency, "USD", file: file, line: line)
        XCTAssertEqual(bidInfo?.creativeId, "test-creative-id-1", file: file, line: line)
        XCTAssertEqual(bidInfo?.adId, "test-ad-id-12345", file: file, line: line)
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31", file: file, line: line)
    }

    private func assertNoBidAttached(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(bidInfo?.targetingKeywords, file: file, line: line)
        XCTAssertNil(bidInfo?.price, file: file, line: line)
        XCTAssertNil(bidInfo?.currency, file: file, line: line)
        XCTAssertNil(bidInfo?.creativeId, file: file, line: line)
        XCTAssertNil(bidInfo?.adId, file: file, line: line)
    }

    func testSetAdPosition() {
        let adUnit = MediationBaseInterstitialAdUnit(
            configId: "test",
            mediationDelegate: MockEmptyPrebidMediationDelegate()
        )
        
        let adUnitConfig = adUnit.adUnitConfig
        
        adUnit.adPosition = .header
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .header)
        
        adUnit.adPosition = .footer
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .footer)
    }
}

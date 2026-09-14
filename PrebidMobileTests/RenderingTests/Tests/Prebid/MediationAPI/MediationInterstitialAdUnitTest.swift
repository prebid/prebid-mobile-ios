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

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

class MediationBannerAdUnitTest: XCTestCase {
    
    var adObject: MockAdObject?
    var mediationDelegate: PrebidMediationDelegate?
    
    let testID = "auid"
    let primarySize = CGSize(width: 320, height: 50)
    
    private func getSDKConfiguration() -> Prebid {
        let config = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        config.prebidServerAccountId = Prebid.devintAccountID
        return config
    }
    
    private let targeting = Targeting.shared
    
    override func setUp() {
        super.setUp()
        
        self.adObject = MockAdObject()
        self.mediationDelegate = MockMediationUtils(adObject: adObject!)
    }
    
    func testConfigSetup() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerAdUnit.additionalSizes = moreSizes
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i], moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerAdUnit.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testAdFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        // Default: display banner only
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Single format
        bannerAdUnit.adFormats = [.video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
        
        // Multiformat
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatIsBackedByAdFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        
        XCTAssertEqual(bannerAdUnit.adFormat, .banner)
        
        // Legacy setter replaces the whole set
        bannerAdUnit.adFormat = .video
        XCTAssertEqual(bannerAdUnit.adFormat, .video)
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(bannerAdUnit.adUnitConfig.adFormats, [.video])
        
        // New setter is visible through the legacy getter
        bannerAdUnit.adFormats = [.banner]
        XCTAssertEqual(bannerAdUnit.adFormat, .banner)
        
        // Legacy getter returns a member of a multiformat set
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertTrue(bannerAdUnit.adFormats.contains(bannerAdUnit.adFormat))
    }
    
    func testAdFormatsRejectsEmptySet() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        bannerAdUnit.adFormats = [.banner, .video]
        
        bannerAdUnit.adFormats = []
        
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video], "Empty set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    func testAdFormatsRejectsUnsupportedFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        // Unsupported only
        bannerAdUnit.adFormats = [.native]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner], "Native-only set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Mixed supported + unsupported must be rejected as a whole
        bannerAdUnit.adFormats = [.banner, .video, .native]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner], "Set containing native must be ignored entirely")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // A valid set is still accepted afterwards
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatRejectsUnsupportedFormat() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        
        bannerAdUnit.adFormat = .video
        bannerAdUnit.adFormat = .native
        
        XCTAssertEqual(bannerAdUnit.adFormat, .video, "Legacy setter must go through the same validation")
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(bannerAdUnit.adUnitConfig.adFormats, [.video])
    }
    
    func testAdObjectSetUpCleanUp() {
       
        //a good response with a bid
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let initialKeywords = "key1,key2"
        
        adObject!.keywords = initialKeywords
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MediationBannerAdUnit(configID: configId, size: primarySize, mediationDelegate: mediationDelegate!)
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: getSDKConfiguration(),
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
                           sdkConfiguration: getSDKConfiguration(),
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
        let adUnit = MediationBannerAdUnit(configID: configId, size: primarySize, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        assertWinningBidEconomics(bidInfo)
        XCTAssertEqual(bidInfo?.targetingKeywords?["hb_pb"], "0.10")

        XCTAssertTrue(adObject!.keywords!.contains("hb_pb:0.10"))
        XCTAssertEqual(adObject!.localExtras?[MockMediationConfigIdKey] as? String, configId)
        XCTAssertTrue(adObject!.localExtras?[MockMediationAdUnitBidKey] is Bid)
    }

    func testFetchDemandBidInfoOnServerError() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.serverErrorResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidServerError)
        XCTAssertNil(bidInfo?.targetingKeywords)
        XCTAssertNil(bidInfo?.price)
        XCTAssertNil(bidInfo?.creativeId)
    }

    func testFetchDemandBidInfoWhenAdObjectSetUpFails() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: MockRejectingMediationDelegate())

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        // Nothing was attached to the ad object, so only the request id is reported
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31")
        assertNoBidAttached(bidInfo)
    }

    func testFetchDemandBidInfoKeepsCompletionForAutoRefresh() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        _ = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertNotNil(adUnit.lastCompletion, "The refresh timer re-runs the request with the stored completion")
        XCTAssertTrue(adUnit.lastAdView === adObject)
    }

    func testFetchDemandWithoutCompletionStillSkipsAutoRefresh() {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: getSDKConfiguration(),
                           targeting: targeting,
                           completion: nil)

        // The request has been handled once the requester is released.
        // The predicate is polled roughly once a second.
        let requestFinished = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in adUnit.bidRequester == nil },
            object: nil
        )
        wait(for: [requestFinished], timeout: 5)

        XCTAssertNil(adUnit.lastCompletion)
        XCTAssertNil(adUnit.lastAdView)
    }

    private func fetchBidInfo(_ adUnit: MediationBannerAdUnit, response: PrebidServerResponse) -> BidInfo? {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(response)
        }])

        let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")
        var result: BidInfo?

        adUnit.fetchDemandBidInfo(connection: connection,
                                  sdkConfiguration: getSDKConfiguration(),
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

    // MARK: - Auto-refresh vs. video creatives
    
    // The adapters hand the rendered `DisplayView` to AdMob / MAX, which embed it somewhere
    // inside the publisher's ad view. The gate must find it there and follow its playback state.
    func testRefreshIsSkippedWhileMediatedVideoIsPlaying() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        guard let mayRefreshNow = adUnit.autoRefreshManager?.mayRefreshNowBlock else {
            return XCTFail("The ad unit must own an AutoRefreshManager")
        }
        
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 480)))
        window.addSubview(adObject!)
        window.isHidden = false
        defer { window.isHidden = true }
        adUnit.lastAdView = adObject
        
        // An HTML creative, or nothing yet: refresh as usual
        let hostWrapper = UIView(frame: adObject!.bounds)
        adObject!.addSubview(hostWrapper)
        hostWrapper.addSubview(UIView(frame: hostWrapper.bounds))
        XCTAssertFalse(adUnit.isVideoPlaying)
        XCTAssertTrue(mayRefreshNow(), "Sanity: a visible ad object without a playing video may refresh")
        
        // The host SDK embeds the Prebid-rendered creative below its own wrapper views
        let displayView = DisplayView(frame: hostWrapper.bounds, bid: Bid(bid: ORTBBid(bidID: "", impid: "", price: 0.1)), configId: testID)
        hostWrapper.addSubview(displayView)
        
        displayView.videoAdDidStart()
        XCTAssertTrue(adUnit.isVideoPlaying)
        XCTAssertFalse(mayRefreshNow(), "A mediated video creative in flight must not be torn down by auto-refresh")
        
        displayView.videoAdDidFinish()
        XCTAssertFalse(adUnit.isVideoPlaying)
        XCTAssertTrue(mayRefreshNow(), "Once the video has finished the next tick must proceed")
    }
    
    func testVideoStateFollowsTheCreativeOnScreen() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        adUnit.lastAdView = adObject
        
        let displayView = DisplayView(frame: adObject!.bounds, bid: Bid(bid: ORTBBid(bidID: "", impid: "", price: 0.1)), configId: testID)
        adObject!.addSubview(displayView)
        displayView.videoAdDidStart()
        XCTAssertTrue(adUnit.isVideoPlaying)
        
        // The host SDK replaces the creative (its own ad, or the next Prebid creative)
        displayView.removeFromSuperview()
        XCTAssertFalse(adUnit.isVideoPlaying, "A creative that is no longer on screen must not block refresh")
        
        // A new fetch cycle starts: nothing is tracked until a creative is on screen again
        adUnit.lastAdView = nil
        XCTAssertFalse(adUnit.isVideoPlaying)
    }
}

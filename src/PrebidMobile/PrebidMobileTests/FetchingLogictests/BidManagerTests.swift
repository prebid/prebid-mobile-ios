/*   Copyright 2018-2019 Prebid.org, Inc.

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
//@testable import GoogleMobileAds
//@testable import MoPub

class BidManagerTests: XCTestCase {

    var request: URLRequest!
    var jsonRequestBody = [String: Any]()
    var loadAdSuccesfulException: XCTestExpectation?
    var timeoutForImpbusRequest: TimeInterval = 0.0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        timeoutForImpbusRequest = 10.0
        PBHTTPStubbingManager.shared().enable()
        PBHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        PBHTTPStubbingManager.shared().broadcastRequests = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.pbhttpStubURLProtocolRequestDidLoad, object: nil)
        request = nil
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        PBHTTPStubbingManager.shared().disable()
        PBHTTPStubbingManager.shared().removeAllStubs()
        PBHTTPStubbingManager.shared().broadcastRequests = false
        loadAdSuccesfulException = nil
    }

    // MARK: - Test methods.
    func testAppNexusBidManagerAdUnitRequest() {
        stubAppNexusRequestWithResponse("responseAppNexusPBM")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testRubiconBidManagerAdUnitRequest() {
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon

        stubAppNexusRequestWithResponse("responseRubiconPBM")
        let bannerUnit = BannerAdUnit(configId: Constants.pbsConfigId300x250Rubicon, size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvaidBidResponseNoCacheId() {

        stubAppNexusRequestWithResponse("responseInvalidResponseWithoutCacheId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForBidResponseFromTwoBidders() {
        stubAppNexusRequestWithResponse("PrebidServerOneBidFromAppNexusOneBidFromRubicon")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess)
            XCTAssertNotNil(bidResponse)
            let keywords = bidResponse?.customKeywords
            XCTAssertEqual(15, keywords?.count)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForBidResponseOneSeatHasCacheIdAnotherSeatDoesNot() {
        stubAppNexusRequestWithResponse("PrebidServerValidResponseAppNexusNoCacheIdAndRunbiconHasCacheId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess)
            XCTAssertNotNil(bidResponse)
            let keywords = bidResponse?.customKeywords
            XCTAssertEqual(10, keywords?.count)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)

    }

    func testBidManagerRequestForBidResponeTwoBidsOnTheSameSeat() {
        stubAppNexusRequestWithResponse("responseValidTwoBidsOnTheSameSeat")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess)
            XCTAssertNotNil(bidResponse)
            let keywords = bidResponse?.customKeywords
            XCTAssertEqual(10, keywords?.count)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)

    }

    func testBidManagerRequestForBidResponseTopBidNoCacheId() {
        stubAppNexusRequestWithResponse("responseInvalidNoTopCacheId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids)
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testAppNexusBidManagerRequestForNoBidResponse() {
        stubAppNexusRequestWithResponse("noBidResponseAppNexus")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testRubiconBidManagerRequestForNoBidResponse() {
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon

        stubRubiconRequestWithResponse("noBidResponseRubicon")
        let bannerUnit = BannerAdUnit(configId: Constants.pbsConfigId300x250Rubicon, size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testAppNexusBidManagerRequestForSuccessfulBidResponse() {
        stubAppNexusRequestWithResponse("responseAppNexusPBM")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            if let bidResponse = bidResponse {
                XCTAssertEqual("appnexus", bidResponse.customKeywords["hb_bidder"])
                XCTAssertEqual("appnexus", bidResponse.customKeywords["hb_bidder_appnexus"])
                XCTAssertEqual("7008d51d-af2a-4357-acea-1cb672ac2189", bidResponse.customKeywords["hb_cache_id"])
                XCTAssertEqual("7008d51d-af2a-4357-acea-1cb672ac2189", bidResponse.customKeywords["hb_cache_id_appnexus"])
                XCTAssertEqual("mobile-app", bidResponse.customKeywords["hb_env"])
                XCTAssertEqual("mobile-app", bidResponse.customKeywords["hb_env_appnexus"])
                XCTAssertEqual("0.50", bidResponse.customKeywords["hb_pb"])
                XCTAssertEqual("0.50", bidResponse.customKeywords["hb_pb_appnexus"])
                XCTAssertEqual("300x250", bidResponse.customKeywords["hb_size"])
                XCTAssertEqual("300x250", bidResponse.customKeywords["hb_size_appnexus"])
                self.loadAdSuccesfulException?.fulfill()
            } else {
                self.loadAdSuccesfulException = nil
            }
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testRubiconBidManagerRequestForSuccessfulBidResponse() {
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon

        stubRubiconRequestWithResponse("responseRubiconPBM")
        let bannerUnit = BannerAdUnit(configId: Constants.pbsConfigId300x250Rubicon, size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            if let bidResponse = bidResponse {

                XCTAssertEqual("mobile-app", bidResponse.customKeywords["hb_env"])
                XCTAssertEqual("https://prebid-cache-europe.rubiconproject.com/cache", bidResponse.customKeywords["hb_cache_hostpath"])
                XCTAssertEqual("300x250", bidResponse.customKeywords["hb_size_rubicon"])
                XCTAssertEqual("a2f41588-4727-425c-9ef0-3b382debef1e", bidResponse.customKeywords["hb_cache_id"])
                XCTAssertEqual("/cache", bidResponse.customKeywords["hb_cache_path_rubicon"])
                XCTAssertEqual("prebid-cache-europe.rubiconproject.com", bidResponse.customKeywords["hb_cache_host_rubicon"])
                XCTAssertEqual("1.20", bidResponse.customKeywords["hb_pb"])
                XCTAssertEqual("1.20", bidResponse.customKeywords["hb_pb_rubicon"])
                XCTAssertEqual("a2f41588-4727-425c-9ef0-3b382debef1e", bidResponse.customKeywords["hb_cache_id_rubicon"])
                XCTAssertEqual("/cache", bidResponse.customKeywords["hb_cache_path"])
                XCTAssertEqual("300x250", bidResponse.customKeywords["hb_size"])
                XCTAssertEqual("https://prebid-cache-europe.rubiconproject.com/cache", bidResponse.customKeywords["hb_cache_hostpath_rubicon"])
                XCTAssertEqual("mobile-app", bidResponse.customKeywords["hb_env_rubicon"])
                XCTAssertEqual("rubicon", bidResponse.customKeywords["hb_bidder"])
                XCTAssertEqual("rubicon", bidResponse.customKeywords["hb_bidder_rubicon"])
                XCTAssertEqual("prebid-cache-europe.rubiconproject.com", bidResponse.customKeywords["hb_cache_host"])
                self.loadAdSuccesfulException?.fulfill()
            } else {
                self.loadAdSuccesfulException = nil
            }
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidAccountId() {
        stubAppNexusRequestWithResponse("responseInvalidAccountId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidInvalidAccountId, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidConfigId() {
        stubAppNexusRequestWithResponse("responseInvalidConfigId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidInvalidConfigId, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidSizeId() {
        stubAppNexusRequestWithResponse("responseinvalidSize")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 0, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForIncorrectFormatOfConfigIdOrAccountId() {
        stubAppNexusRequestWithResponse("responseIncorrectFormat")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidServerError, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func requestCompleted(_ notification: Notification?) {
        var incomingRequest = notification?.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = Constants.utAdRequestBaseUrl
        if request == nil && requestString?.range(of: searchString) != nil {
            request = notification!.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String: Any]
        }
    }

    // MARK: - Stubbing
    func stubAppNexusRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = PBURLConnectionStub()
        requestStub.requestURL = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        requestStub.responseCode = 200
        requestStub.responseBody = baseResponse
        PBHTTPStubbingManager.shared().add(requestStub)
    }

    func stubRubiconRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = PBURLConnectionStub()
        requestStub.requestURL = "https://prebid-server.rubiconproject.com/openrtb2/auction"
        requestStub.responseCode = 200
        requestStub.responseBody = baseResponse
        PBHTTPStubbingManager.shared().add(requestStub)
    }

    func testTimeoutMillisUpdate() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseAppNexus")
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillis == 2000)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillis > 700 && Prebid.shared.timeoutMillis < 800)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate2() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseNoTmax")
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillis == 2000)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(!Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillis == 2000)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate3() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseTmaxTooLarge")
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillis == 2000)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillis == 2000)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate4() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseNoTmaxEdite")
        Prebid.shared.timeoutMillis = 1000
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillis == 1000)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(!Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillis == 1000)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}

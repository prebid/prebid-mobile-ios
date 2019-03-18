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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        PBHTTPStubbingManager.shared().disable()
        PBHTTPStubbingManager.shared().removeAllStubs()
        PBHTTPStubbingManager.shared().broadcastRequests = false
        loadAdSuccesfulException = nil
    }

    // MARK: - Test methods.
    func testBidManagerAdUnitRequest() {
        stubRequestWithResponse("responsePBM")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvaidBidResponseNoCacheId() {
        stubRequestWithResponse("responseInvalidResponseWithoutCacheId")
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
        stubRequestWithResponse("PrebidServerOneBidFromAppNexusOneBidFromRubicon")
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
        stubRequestWithResponse("PrebidServerValidResponseAppNexusNoCacheIdAndRunbiconHasCacheId")
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
        stubRequestWithResponse("responseValidTwoBidsOnTheSameSeat")
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
        stubRequestWithResponse("responseInvalidNoTopCacheId")
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

    func testBidManagerRequestForNoBidResponse() {
        stubRequestWithResponse("noBidResponse")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForSuccessfulBidResponse() {
        stubRequestWithResponse("responsePBM")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            if (bidResponse != nil) {
                XCTAssertEqual("appnexus", bidResponse?.customKeywords["hb_bidder"])
                XCTAssertEqual("appnexus", bidResponse?.customKeywords["hb_bidder_appnexus"])
                XCTAssertEqual("7008d51d-af2a-4357-acea-1cb672ac2189", bidResponse?.customKeywords["hb_cache_id"])
                XCTAssertEqual("7008d51d-af2a-4357-acea-1cb672ac2189", bidResponse?.customKeywords["hb_cache_id_appnexus"])
                XCTAssertEqual("mobile-app", bidResponse?.customKeywords["hb_env"])
                XCTAssertEqual("mobile-app", bidResponse?.customKeywords["hb_env_appnexus"])
                XCTAssertEqual("0.50", bidResponse?.customKeywords["hb_pb"])
                XCTAssertEqual("0.50", bidResponse?.customKeywords["hb_pb_appnexus"])
                XCTAssertEqual("300x250", bidResponse?.customKeywords["hb_size"])
                XCTAssertEqual("300x250", bidResponse?.customKeywords["hb_size_appnexus"])
                self.loadAdSuccesfulException?.fulfill()
            } else {
                self.loadAdSuccesfulException = nil
            }
        }
        loadAdSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidAccountId() {
        stubRequestWithResponse("responseInvalidAccountId")
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
        stubRequestWithResponse("responseInvalidConfigId")
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
        stubRequestWithResponse("responseinvalidSize")
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
        stubRequestWithResponse("responseIncorrectFormat")
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
    func stubRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = PBURLConnectionStub()
        requestStub.requestURL = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        requestStub.responseCode = 200
        requestStub.responseBody = baseResponse
        PBHTTPStubbingManager.shared().add(requestStub)
    }

    func testTimeoutMillisUpdate() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubRequestWithResponse("noBidResponse")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
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
        stubRequestWithResponse("noBidResponseNoTmax")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
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
        stubRequestWithResponse("noBidResponseTmaxTooLarge")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
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
        stubRequestWithResponse("noBidResponseNoTmaxEdite")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
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

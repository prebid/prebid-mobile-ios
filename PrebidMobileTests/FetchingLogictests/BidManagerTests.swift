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
import TestUtils
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
        Prebid.shared.prebidServerHost = .Appnexus
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
    func testAppNexusBidManagerAdUnitRequest() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseAppNexusPBM")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testRubiconBidManagerAdUnitRequest() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = Constants.pbsRubiconAccount_id
        
        stubRubiconRequestWithResponse("responseRubiconPBM")
        let bannerUnit = BannerAdUnit(configId: Constants.pbsConfigId300x250Rubicon, size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvaidBidResponseNoCacheId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseInvalidResponseWithoutCacheId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids, resultCode.name())
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForBidResponseFromTwoBidders() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
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
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForBidResponseOneSeatHasCacheIdAnotherSeatDoesNot() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
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
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)

    }

    func testBidManagerRequestForBidResponeTwoBidsOnTheSameSeat() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
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
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)

    }

    func testBidManagerRequestForBidResponseTopBidNoCacheId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseInvalidNoTopCacheId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids)
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testAppNexusBidManagerRequestForNoBidResponse() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseAppNexus")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testRubiconBidManagerRequestForNoBidResponse() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = Constants.pbsRubiconAccount_id
        
        stubRubiconRequestWithResponse("noBidResponseRubicon")
        let bannerUnit = BannerAdUnit(configId: Constants.pbsConfigId300x250Rubicon, size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testAppNexusBidManagerRequestForSuccessfulBidResponse() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
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
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testRubiconBidManagerRequestForSuccessfulBidResponse() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = Constants.pbsRubiconAccount_id
        
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
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidAccountId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseInvalidAccountId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidInvalidAccountId, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidConfigId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseInvalidConfigId")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidInvalidConfigId, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForInvalidSizeId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseinvalidSize")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 0, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in
            XCTAssertNil(bidResponse)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testBidManagerRequestForIncorrectFormatOfConfigIdOrAccountId() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("responseIncorrectFormat")
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidServerError, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testBlankResponseReturnsNoBid() {
        loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("emptyResponse", responseCode: 204)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(ResultCode.prebidDemandNoBids, resultCode)
            self.loadAdSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func requestCompleted(_ notification: Notification?) {
        let incomingRequest = notification?.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = Constants.utAdRequestBaseUrl
        if request == nil && requestString?.range(of: searchString) != nil {
            request = notification!.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String: Any]
        }
    }

    // MARK: - Stubbing
    func stubAppNexusRequestWithResponse(_ responseName: String?, responseCode: Int = 200) {
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = PBURLConnectionStub()
        requestStub.requestURL = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        requestStub.responseCode = responseCode
        requestStub.responseBody = baseResponse
        PBHTTPStubbingManager.shared().add(requestStub)
    }
    
    func stubRubiconRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
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
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == Prebid.shared.timeoutMillis)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillisDynamic > 700 && Prebid.shared.timeoutMillisDynamic < 800)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate2() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseNoTmax")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == Prebid.shared.timeoutMillis)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(!Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == Prebid.shared.timeoutMillis)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate3() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseTmaxTooLarge")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == Prebid.shared.timeoutMillis)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == Prebid.shared.timeoutMillis)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testTimeoutMillisUpdate4() {
        let loadAdSuccesfulException = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("noBidResponseNoTmaxEdite")
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.timeoutMillis = 1000
        XCTAssertTrue(!Prebid.shared.timeoutUpdated)
        XCTAssertTrue(Prebid.shared.timeoutMillis == 1000)
        XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == 1000)
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (_, _) in
            XCTAssertTrue(!Prebid.shared.timeoutUpdated)
            XCTAssertTrue(Prebid.shared.timeoutMillisDynamic == 1000)
            loadAdSuccesfulException.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}

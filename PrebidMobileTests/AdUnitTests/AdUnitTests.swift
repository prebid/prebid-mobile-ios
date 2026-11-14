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
@_spi(PBMInternal) @testable import PrebidMobile

class AdUnitTests: XCTestCase {

    override func tearDown() {
        Targeting.shared.clearUserKeywords()
        Targeting.shared.forceSdkToChooseWinner = true
        
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        Prebid.shared.timeoutMillis = 2000
        Prebid.shared.prebidServerAccountId = ""
    }

    func testFetchDemand() {
        //given
        let expectation = expectation(description: "\(#function)")
        let adObject = NSMutableDictionary()
        var resultCode: ResultCode?
        
        let adUnit = makeAdUnit(respondingWith: BidResponseTransformer.makeValidCachedResponse(bidPrice: 0.75).jsonDict)
        
        //when
        adUnit.fetchDemand(adObject: adObject) { (code: ResultCode) in
            resultCode = code
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        //then
        XCTAssertEqual(resultCode, .prebidDemandFetchSuccess)
        XCTAssertEqual(adObject["hb_bidder"] as? String, "openx", "The winning bid's targeting is attached to the ad object")
    }
    
    func testFetchDemandBids() {
        //given
        let expectation = expectation(description: "\(#function)")
        var codeResult: ResultCode?
        var kvDictResult: [String:String]?
        
        let adUnit = makeAdUnit(respondingWith: BidResponseTransformer.makeValidCachedResponse(bidPrice: 0.75).jsonDict)
        
        //when
        adUnit.fetchDemand { bidInfo in
            codeResult = bidInfo.resultCode
            kvDictResult = bidInfo.targetingKeywords
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        //then
        XCTAssertEqual(codeResult, .prebidDemandFetchSuccess)
        XCTAssertEqual(kvDictResult?["hb_bidder"], "openx")
        XCTAssertEqual(kvDictResult?["hb_pb"], "0.10")
    }
    
    func testFetchDemandBidInfo() {
        //given
        let expectation = expectation(description: "\(#function)")
        
        var realBidInfo: BidInfo?
        
        guard let json = UtilitiesForTesting.loadFileAsDictFromBundle("sample_ortb_native_with_win_event.json") else {
            XCTFail("Couldn't load `sample_ortb_native_with_win_event.json` file.")
            return
        }
        
        let adUnit = makeAdUnit(respondingWith: json, adFormats: [.native])
        
        //when
        adUnit.fetchDemand { bidInfo in
            realBidInfo = bidInfo
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        //then
        XCTAssertEqual(realBidInfo?.resultCode, .prebidDemandFetchSuccess)
        XCTAssertEqual(realBidInfo?.targetingKeywords?["hb_bidder"], "prebid")
        XCTAssertEqual(realBidInfo?.exp, 116)
        XCTAssertNotNil(realBidInfo?.nativeAdCacheId, "A native winning bid is cached locally")
        XCTAssertEqual(realBidInfo?.targetingKeywords?[PrebidLocalCacheIdKey], realBidInfo?.nativeAdCacheId)
    }

    /// An ad unit whose bid requester answers with `json` instead of calling Prebid Server.
    private func makeAdUnit(respondingWith json: [String: Any]?, adFormats: Set<AdFormat> = [.banner]) -> AdUnit {
        Prebid.shared.prebidServerAccountId = "test-account-id"
        return AdUnit(
            bidRequester: MockPBMBidRequester(jsonDictionary: json ?? [:]),
            configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4",
            size: CGSize(width: 300, height: 250),
            adFormats: adFormats
        )
    }

    /// `setAutoRefreshMillis(time:)` accepts 30 s or more. Tests that wait for a refresh create the dispatcher it
    /// would create, with an 800 ms interval.
    private func useShortAutoRefresh(_ adUnit: AdUnit) {
        adUnit.initDispatcher(refreshTime: 800)
    }
    
    //forceSdkToChooseWinner + Winner = Contains Targeting Info
    func testForcedWinnerAndWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //forceSdkToChooseWinner + No Winner = Doesn't contain Targeting Info
    func testForcedWinnerAndLoosingBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        let expected = ResultCode.prebidDemandNoBids
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeValidResponseWithNonWinningTargetingInfo()
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertFalse((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + Winner = Contains Targeting Info
    func testNonForcedWinnerAndWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + No Winner = Contains Targeting Info
    func testNonForcedWinnerAndNonWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeValidResponseWithNonWinningTargetingInfo()
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(adObject["hb_bidder"] as? String, "Test-Bidder-1")
        XCTAssertEqual(resultCode, expected)
    }
    
    //forceSdkToChooseWinner + Native Format Winner = Contains Targeting Info
    func testForcedWinnerAndWinningBidNativeFormat() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.native])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeNativeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertNotNil(bidResponse.targetingInfo?[PrebidLocalCacheIdKey])
        XCTAssertTrue((adObject.allKeys as? [String])?.contains(PrebidLocalCacheIdKey) ?? false)
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + Native Format Winner = Contains Targeting Info
    func testNonForcedWinnerAndWinningBidNativeFormat() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.native])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = BidResponseTransformer.makeNativeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertNotNil(bidResponse.targetingInfo?[PrebidLocalCacheIdKey])
        XCTAssertTrue((adObject.allKeys as? [String])?.contains(PrebidLocalCacheIdKey) ?? false)
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    // A promoted runner-up is still delivered demand, so publishers gating on
    // `resultCode == .prebidDemandFetchSuccess` must not drop it.
    func testPromotedWinnerAfterFilteringReportsFetchSuccess() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true

        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let bidResponse = BidResponse(jsonDictionary: Self.topBidUncachedRunnerUpCachedResponse())

        //when
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 1)
        let resultCode = adUnit.setUp(adObject, with: bidResponse)

        //then
        XCTAssertTrue(bidResponse.topBidWasFiltered)
        XCTAssertEqual(bidResponse.winningBid?.price, 0.10)
        XCTAssertEqual(resultCode, .prebidDemandFetchSuccess)
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder_appnexus") ?? false)
    }

    func testBidInfoCarriesTopBidFilteredFlag() {
        let filtered = BidResponse(jsonDictionary: Self.topBidUncachedRunnerUpCachedResponse())
        filtered.removeBidsWithoutSuccessfulCache()

        let filteredInfo = BidInfo.create(resultCode: .prebidDemandFetchSuccess, bidResponse: filtered)
        XCTAssertTrue(filteredInfo.topBidFiltered)

        let untouched = BidResponse(jsonDictionary: Self.topBidUncachedRunnerUpCachedResponse())
        let untouchedInfo = BidInfo.create(resultCode: .prebidDemandFetchSuccess, bidResponse: untouched)
        XCTAssertFalse(untouchedInfo.topBidFiltered)
    }

    /// PBS-designated winner (unsuffixed hb_* keys, no cache entry) plus a cached runner-up.
    private static func topBidUncachedRunnerUpCachedResponse() -> [String : Any] {
        let topBid: [String : Any] = [
            "id": "top-bid-id",
            "impid": "test-imp-id",
            "price": 0.20,
            "adm": "<html></html>",
            "w": 300,
            "h": 250,
            "ext": [
                "prebid": [
                    "targeting": [
                        "hb_bidder": "openx",
                        "hb_pb": "0.20"
                    ],
                    "type": "banner"
                ]
            ]
        ]

        let runnerUpBid: [String : Any] = [
            "id": "runner-up-bid-id",
            "impid": "test-imp-id",
            "price": 0.10,
            "adm": "<html></html>",
            "w": 300,
            "h": 250,
            "ext": [
                "prebid": [
                    "targeting": [
                        "hb_bidder_appnexus": "appnexus",
                        "hb_pb_appnexus": "0.10"
                    ],
                    "cache": [
                        "bids": [
                            "url": "https://prebid-cache/cache?uuid=runner-up-cache-id",
                            "cacheId": "runner-up-cache-id"
                        ]
                    ],
                    "type": "banner"
                ]
            ]
        ]

        return [
            "id": "response-id",
            "seatbid": [
                [
                    "bid": [topBid, runnerUpBid],
                    "seat": "openx"
                ]
            ],
            "cur": "USD"
        ]
    }

    func testBidInfoCompletion() {
        Prebid.shared.prebidServerAccountId = "test-account-id"
        
        defer {
            Prebid.shared.prebidServerAccountId = ""
        }
        
        guard let json = UtilitiesForTesting.loadFileAsDictFromBundle("sample_ortb_native_with_win_event.json") else {
            XCTFail("Couldn't load `sample_ortb_native_with_win_event.json` file.")
            return
        }
        
        let bidRequester = MockPBMBidRequester(jsonDictionary: json)
        let adUnit = AdUnit(bidRequester: bidRequester, configId: "test-config-id", size: CGSize.zero, adFormats: [])
        
        let expectation = expectation(description: "Fetch demand completed.")
        adUnit.baseFetchDemand { bidInfo in
            expectation.fulfill()
            
            XCTAssertEqual(bidInfo.resultCode, .prebidDemandFetchSuccess)
            
            XCTAssertNotNil(bidInfo.targetingKeywords)
            XCTAssertNotNil(bidInfo.exp)
            XCTAssertNotNil(bidInfo.nativeAdCacheId)
            XCTAssertEqual(bidInfo.events[BidInfo.EVENT_WIN], "https://prebid.org/win",
                           "The win event must come from `ext.prebid.events.win`.")
            XCTAssertEqual(bidInfo.events[BidInfo.EVENT_IMP], "https://prebid.org/imp",
                           "The imp event must come from `ext.prebid.events.imp`.")
            XCTAssertFalse(bidInfo.events.isEmpty)
        }
        
        waitForExpectations(timeout: 30.0)
    }
    
    func testFetchDemandAutoRefresh() {
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        Prebid.shared.prebidServerAccountId = "1001"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        useShortAutoRefresh(adUnit)
        let testObject: AnyObject = () as AnyObject
        
        var fetchDemandCount = 0
        
        //when
        adUnit.fetchDemand(adObject: testObject) { (code: ResultCode) in
            fetchDemandCount += 1
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }
    
    func testFetchDemandResumeAutoRefresh() {
        Prebid.shared.prebidServerAccountId = "1001"
        let requester = MockBidRequester(expectedCalls: [
            { $0(nil, nil) },
            { $0(nil, nil) }
        ])
        let adUnit = AdUnit(bidRequester: requester, configId: "1001-1",
                            size: CGSize(width: 300, height: 250), adFormats: [.banner])
        useShortAutoRefresh(adUnit)
        defer { adUnit.stopAutoRefresh() }

        let initialFetch = expectation(description: "Initial fetch")
        let resumedFetch = expectation(description: "Fetch after resuming")
        var fetchDemandCount = 0
        adUnit.fetchDemand { [weak adUnit] _ in
            fetchDemandCount += 1
            adUnit?.stopAutoRefresh()
            if fetchDemandCount == 1 {
                initialFetch.fulfill()
            } else {
                resumedFetch.fulfill()
            }
        }
        wait(for: [initialFetch], timeout: 5)

        // Keep the run loop moving while paused, so an incorrectly running timer is observable.
        let paused = expectation(description: "Paused longer than the refresh interval")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { paused.fulfill() }
        wait(for: [paused], timeout: 5)
        XCTAssertEqual(fetchDemandCount, 1)

        adUnit.resumeAutoRefresh()
        wait(for: [resumedFetch], timeout: 5)
        XCTAssertEqual(fetchDemandCount, 2)
    }

    func testFetchDemandBidsAutoRefresh() {
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        Prebid.shared.prebidServerAccountId = "1001"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        useShortAutoRefresh(adUnit)
        
        var fetchDemandCount = 0
        
        adUnit.fetchDemand { _ in
            fetchDemandCount += 1
            exception.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)
    }
    
    func testFetchDemandBidsAutoRefreshWithSimilarGlobalTimeout() {
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        guard let json = UtilitiesForTesting.loadFileAsDictFromBundle("sample_ortb_native_with_win_event.json") else {
            XCTFail("Couldn't load `sample_ortb_native_with_win_event.json` file.")
            return
        }
        
        Prebid.shared.timeoutMillis = 800
        Prebid.shared.prebidServerAccountId = "1001"
        
        let bidRequester = MockPBMBidRequester(jsonDictionary: json)
        let adUnit = AdUnit(bidRequester: bidRequester, configId: "1001-1", size: .zero, adFormats: [])
        useShortAutoRefresh(adUnit)
        
        var fetchDemandCount = 0
        
        //when
        adUnit.fetchDemand(completionBidInfo: { bid in
            XCTAssertNotEqual(bid.resultCode, .prebidDemandTimedOut)
            fetchDemandCount += 1
            exception.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)
    }

    func testSetAutoRefreshMillis() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        
        //then
        XCTAssertEqual(adUnit.dispatcher?.repeatInSeconds, 30)
        XCTAssertEqual(adUnit.dispatcher?.state, .notStarted, "Refreshing starts with the first fetchDemand")

        //when: a new interval replaces the old one
        adUnit.setAutoRefreshMillis(time: 45_000)

        //then
        XCTAssertEqual(adUnit.dispatcher?.repeatInSeconds, 45)
    }

    func testSetAutoRefreshMillisSmall() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 29_000)
        
        //then
        XCTAssertNil(adUnit.dispatcher)
    }
    
    func testStopAutoRefresh() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        adUnit.stopDispatcher()
        
        //then
        XCTAssertNil(adUnit.dispatcher?.timer)
    }
        
    func testAdUnitSetAdPosition() {
        let adUnit = AdUnit(
            configId: "test",
            size: CGSize(width: 300, height: 250),
            adFormats: [.banner, .video]
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

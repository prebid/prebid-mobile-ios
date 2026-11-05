/*   Copyright 2018-2026 Prebid.org, Inc.

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

class MediationNativeAdUnitTest: XCTestCase {

    let configId = "prebidConfigId"
    let requestId = "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31"
    let creativeId = "test-creative-id-1"

    var adObject: MockAdObject?
    var mediationDelegate: PrebidMediationDelegate?

    private var cacheIdsBeforeTest: Set<String> = []

    override func setUp() {
        super.setUp()

        adObject = MockAdObject()
        mediationDelegate = MockMediationUtils(adObject: adObject!)
        cacheIdsBeforeTest = Set(CacheManager.shared.savedValuesDict.keys)
    }

    override func tearDown() {
        // The shared cache would keep the native bids a test saves until they expire
        CacheManager.shared.savedValuesDict.keys
            .filter { !cacheIdsBeforeTest.contains($0) }
            .forEach { CacheManager.shared.savedValuesDict.removeValue(forKey: $0) }

        super.tearDown()
    }

    // MARK: - fetchDemandBidInfo

    func testFetchDemandBidInfoProvidesWinningBid() {
        let adUnit = makeAdUnit(mediationDelegate: mediationDelegate!, stubbedBidInfo: makeCachedBidInfo())

        let bidInfo = fetchBidInfo(adUnit)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        XCTAssertEqual(bidInfo?.price, 1.25)
        XCTAssertEqual(bidInfo?.currency, "USD")
        XCTAssertEqual(bidInfo?.creativeId, creativeId)
        XCTAssertEqual(bidInfo?.requestId, requestId)

        XCTAssertEqual(adObject!.localExtras?[MockMediationConfigIdKey] as? String, configId)
        XCTAssertNotNil(adObject!.localExtras?[MockMediationAdNativeResponseKey])
    }

    func testFetchDemandBidInfoWhenAdObjectSetUpFails() {
        let adUnit = makeAdUnit(mediationDelegate: MockRejectingMediationDelegate(), stubbedBidInfo: makeCachedBidInfo())

        let bidInfo = fetchBidInfo(adUnit)

        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        // Nothing was attached to the ad object, so only the request id is reported
        XCTAssertEqual(bidInfo?.requestId, requestId)
        XCTAssertNil(bidInfo?.targetingKeywords)
        XCTAssertNil(bidInfo?.price)
        XCTAssertNil(bidInfo?.currency)
        XCTAssertNil(bidInfo?.creativeId)
        XCTAssertNil(bidInfo?.adId)
    }

    func testFetchDemandBidInfoPassesThroughUnsuccessfulResult() {
        let stubbedBidInfo = BidInfo(resultCode: .prebidDemandNoBids, requestId: requestId)
        let adUnit = makeAdUnit(mediationDelegate: mediationDelegate!, stubbedBidInfo: stubbedBidInfo)

        let bidInfo = fetchBidInfo(adUnit)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandNoBids)
        XCTAssertEqual(bidInfo?.requestId, requestId)
        XCTAssertNil(bidInfo?.price)
        XCTAssertNil(adObject!.localExtras?[MockMediationAdNativeResponseKey])
    }

    func testFetchDemandReportsResultCodeOfAdObjectSetUp() {
        let adUnit = makeAdUnit(mediationDelegate: MockRejectingMediationDelegate(), stubbedBidInfo: makeCachedBidInfo())

        let asyncExpectation = expectation(description: "fetchDemand executed")

        adUnit.fetchDemand { (result: ResultCode) in
            XCTAssertEqual(result, .prebidWrongArguments)
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - Bid read back from the cache

    func testFetchDemandBidInfoHandsBidCachedByAdUnitToAdObject() {
        useDefaultWinnerSelection()
        let targeting = ["hb_pb": "1.20", "hb_bidder": "appnexus", "hb_cache_id": "pbs-cache-id"]
        let adUnit = makeAdUnit(replaying: makeNativeBidResponse(targeting: targeting))

        let bidInfo = fetchBidInfo(adUnit)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        XCTAssertEqual(bidInfo?.requestId, requestId)
        XCTAssertEqual(bidInfo?.price, 1.25)
        XCTAssertEqual(bidInfo?.creativeId, creativeId)

        let nativeResponse = adObject!.localExtras?[MockMediationAdNativeResponseKey] as? [String: Any]
        XCTAssertNotNil(bidInfo?.nativeAdCacheId)
        XCTAssertEqual(nativeResponse?[PrebidLocalCacheIdKey] as? String, bidInfo?.nativeAdCacheId)
    }

    func testFetchDemandBidInfoWhenNoBidWasCached() {
        useDefaultWinnerSelection()
        // Without hb_cache_id the bid is not designated as the winner, so `AdUnit.setUp`
        // reports success without caching it
        let targeting = ["hb_pb": "1.20", "hb_bidder": "appnexus"]
        let adUnit = makeAdUnit(replaying: makeNativeBidResponse(targeting: targeting))

        let bidInfo = fetchBidInfo(adUnit)

        assertNoBidAttached(bidInfo)
    }

    func testFetchDemandBidInfoWhenCachedBidIsGone() {
        let stubbedBidInfo = makeSuccessfulBidInfo(cacheId: "Prebid_expired-cache-id")
        let adUnit = makeAdUnit(mediationDelegate: mediationDelegate!, stubbedBidInfo: stubbedBidInfo)

        let bidInfo = fetchBidInfo(adUnit)

        assertNoBidAttached(bidInfo)
    }

    func testFetchDemandBidInfoWhenCachedBidDoesNotParse() {
        let adUnit = makeAdUnit(mediationDelegate: mediationDelegate!, stubbedBidInfo: makeCachedBidInfo(content: "not a bid"))

        let bidInfo = fetchBidInfo(adUnit)

        assertNoBidAttached(bidInfo)
    }

    func testFetchDemandWhenNoBidWasCached() {
        useDefaultWinnerSelection()
        let adUnit = makeAdUnit(replaying: makeNativeBidResponse(targeting: ["hb_pb": "1.20", "hb_bidder": "appnexus"]))

        let asyncExpectation = expectation(description: "fetchDemand executed")

        adUnit.fetchDemand { (result: ResultCode) in
            XCTAssertEqual(result, .prebidDemandNoBids)
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - Overlapping fetches

    func testFetchWhileAnotherIsInFlight() {
        let adUnit = MediationNativeAdUnit(configId: configId, mediationDelegate: mediationDelegate!)
        let nativeRequest = DeferredNativeRequest(configId: configId)
        adUnit.nativeAdUnit = nativeRequest

        var firstResults: [BidInfo] = []
        var secondResults: [BidInfo] = []
        let firstCompleted = expectation(description: "first fetch completed")
        let secondCompleted = expectation(description: "second fetch completed")
        // The result arrays count the calls; a repeated call must fail an assertion, not the run
        firstCompleted.assertForOverFulfill = false
        secondCompleted.assertForOverFulfill = false

        adUnit.fetchDemandBidInfo { bidInfo in
            firstResults.append(bidInfo)
            firstCompleted.fulfill()
        }
        adUnit.fetchDemandBidInfo { bidInfo in
            XCTAssertTrue(Thread.isMainThread)
            secondResults.append(bidInfo)
            secondCompleted.fulfill()
        }

        // The second fetch completes at once and leaves the first one running
        wait(for: [secondCompleted], timeout: 1)
        XCTAssertEqual(secondResults.map(\.resultCode), [.prebidSDKMisusePreviousFetchNotCompletedYet])
        XCTAssertNil(secondResults.first?.requestId)
        XCTAssertEqual(nativeRequest.completions.count, 1, "Only the first fetch may reach the native request")
        XCTAssertTrue(firstResults.isEmpty)

        // The first fetch gets its own result
        guard let firstRequestCompletion = nativeRequest.completions.first else {
            return XCTFail("The first fetch did not reach the native request")
        }
        firstRequestCompletion(BidInfo(resultCode: .prebidDemandNoBids, requestId: requestId))
        wait(for: [firstCompleted], timeout: 1)
        drainMainQueue()

        XCTAssertEqual(firstResults.map(\.resultCode), [.prebidDemandNoBids])
        XCTAssertEqual(firstResults.first?.requestId, requestId)
        XCTAssertEqual(secondResults.count, 1)

        // Once the first fetch has completed, a new one reaches the native request
        adUnit.fetchDemandBidInfo { _ in }
        XCTAssertEqual(nativeRequest.completions.count, 2)
    }

    func testFetchDemandBidInfoDoesNotKeepCompletionAfterItRuns() {
        let stubbedBidInfo = BidInfo(resultCode: .prebidDemandNoBids, requestId: requestId)
        let adUnit = makeAdUnit(mediationDelegate: mediationDelegate!, stubbedBidInfo: stubbedBidInfo)
        weak var capturedByCompletion: NSObject?

        autoreleasepool {
            let object = NSObject()
            capturedByCompletion = object
            let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")

            adUnit.fetchDemandBidInfo { _ in
                withExtendedLifetime(object) {}
                asyncExpectation.fulfill()
            }
            wait(for: [asyncExpectation], timeout: 1)
        }

        // `MockNativeRequest` keeps nothing, so only the ad unit could still hold the completion
        XCTAssertNil(capturedByCompletion)
    }

    // MARK: - Private Methods

    private func makeAdUnit(mediationDelegate: PrebidMediationDelegate, stubbedBidInfo: BidInfo) -> MediationNativeAdUnit {
        let adUnit = MediationNativeAdUnit(configId: configId, mediationDelegate: mediationDelegate)
        let nativeRequest = MockNativeRequest(configId: configId)
        nativeRequest.stubbedBidInfo = stubbedBidInfo
        adUnit.nativeAdUnit = nativeRequest
        return adUnit
    }

    private func fetchBidInfo(_ adUnit: MediationNativeAdUnit) -> BidInfo? {
        let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")
        var result: BidInfo?

        adUnit.fetchDemandBidInfo { bidInfo in
            XCTAssertTrue(Thread.isMainThread)
            result = bidInfo
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        return result
    }

    /// A successful `BidInfo` whose native bid is in the local cache, as `NativeRequest` reports it.
    private func makeCachedBidInfo(content: String = "{\"adm\":\"{}\"}") -> BidInfo {
        let cacheId = CacheManager.shared.save(content: content)
        XCTAssertNotNil(cacheId, "The native bid must be cached")

        return makeSuccessfulBidInfo(cacheId: cacheId ?? "")
    }

    /// A successful `BidInfo` whose targeting points at the native bid cached under `cacheId`.
    private func makeSuccessfulBidInfo(cacheId: String) -> BidInfo {
        BidInfo(
            resultCode: .prebidDemandFetchSuccess,
            targetingKeywords: ["hb_pb": "1.20", PrebidLocalCacheIdKey: cacheId],
            nativeAdCacheId: cacheId,
            price: 1.25,
            currency: "USD",
            creativeId: creativeId,
            requestId: requestId
        )
    }

    private func makeAdUnit(replaying response: [String: Any]) -> MediationNativeAdUnit {
        let adUnit = MediationNativeAdUnit(configId: configId, mediationDelegate: mediationDelegate!)
        let nativeRequest = ReplayingNativeRequest(configId: configId)
        nativeRequest.response = response
        adUnit.nativeAdUnit = nativeRequest
        return adUnit
    }

    /// A Prebid Server response whose only bid is a native one with the given targeting.
    private func makeNativeBidResponse(targeting: [String: String]) -> [String: Any] {
        [
            "id": requestId,
            "cur": "USD",
            "seatbid": [[
                "seat": "appnexus",
                "bid": [[
                    "id": "native-bid",
                    "impid": "imp",
                    "price": 1.25,
                    "adm": "{\"assets\":[]}",
                    "crid": creativeId,
                    "ext": ["prebid": ["type": "native", "targeting": targeting]]
                ]]
            ]]
        ]
    }

    /// Sets the defaults `AdUnit.setUp` relies on: a bid is the winner only with `hb_pb`, `hb_bidder`
    /// and `hb_cache_id`, and bids without a winner still report success. Other tests change both.
    private func useDefaultWinnerSelection() {
        let forceSdkToChooseWinner = Targeting.shared.forceSdkToChooseWinner
        let useCacheForReporting = Prebid.shared.useCacheForReportingWithRenderingAPI
        addTeardownBlock {
            Targeting.shared.forceSdkToChooseWinner = forceSdkToChooseWinner
            Prebid.shared.useCacheForReportingWithRenderingAPI = useCacheForReporting
        }

        Targeting.shared.forceSdkToChooseWinner = false
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
    }

    private func assertNoBidAttached(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandNoBids, file: file, line: line)
        // The request was made, but nothing was attached to the ad object
        XCTAssertEqual(bidInfo?.requestId, requestId, file: file, line: line)
        XCTAssertNil(bidInfo?.targetingKeywords, file: file, line: line)
        XCTAssertNil(bidInfo?.nativeAdCacheId, file: file, line: line)
        XCTAssertNil(bidInfo?.price, file: file, line: line)
        XCTAssertNil(bidInfo?.currency, file: file, line: line)
        XCTAssertNil(bidInfo?.creativeId, file: file, line: line)
        XCTAssertNil(adObject!.localExtras?[MockMediationAdNativeResponseKey], file: file, line: line)
    }

    /// Runs what the main queue already holds, so a second completion would have arrived by now.
    private func drainMainQueue() {
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async {
            drained.fulfill()
        }
        wait(for: [drained], timeout: 1)
    }
}

/// A native request that runs a stored Prebid Server response through `AdUnit.setUp`,
/// the steps `AdUnit.baseFetchDemand` takes once the response has arrived, without the network.
private class ReplayingNativeRequest: NativeRequest {
    var response: [String: Any] = [:]

    override func fetchDemand(completionBidInfo: @escaping (BidInfo) -> Void) {
        let bidResponse = BidResponse(jsonDictionary: response)
        let resultCode = setUp(nil, with: bidResponse)
        let bidInfo = BidInfo.create(resultCode: resultCode, bidResponse: bidResponse)

        DispatchQueue.main.async {
            completionBidInfo(bidInfo)
        }
    }
}

/// A native request that keeps the completions it is given, so a test decides when each request answers.
private class DeferredNativeRequest: NativeRequest {
    private(set) var completions: [(BidInfo) -> Void] = []

    override func fetchDemand(completionBidInfo: @escaping (BidInfo) -> Void) {
        completions.append(completionBidInfo)
    }
}

/// A native request that reports a stubbed `BidInfo` instead of calling Prebid Server.
private class MockNativeRequest: NativeRequest {
    var stubbedBidInfo: BidInfo?

    override func fetchDemand(completionBidInfo: @escaping (BidInfo) -> Void) {
        guard let stubbedBidInfo else {
            XCTFail("MockNativeRequest: stubbedBidInfo is not set")
            return
        }

        DispatchQueue.main.async {
            completionBidInfo(stubbedBidInfo)
        }
    }
}

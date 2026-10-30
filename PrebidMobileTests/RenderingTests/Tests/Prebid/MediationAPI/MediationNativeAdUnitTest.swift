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

    override func setUp() {
        super.setUp()

        adObject = MockAdObject()
        mediationDelegate = MockMediationUtils(adObject: adObject!)
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
    private func makeCachedBidInfo() -> BidInfo {
        let cacheId = CacheManager.shared.save(content: "{\"adm\":\"{}\"}")
        XCTAssertNotNil(cacheId, "The native bid must be cached")

        return BidInfo(
            resultCode: .prebidDemandFetchSuccess,
            targetingKeywords: ["hb_pb": "1.20", PrebidLocalCacheIdKey: cacheId ?? ""],
            nativeAdCacheId: cacheId,
            price: 1.25,
            currency: "USD",
            creativeId: creativeId,
            requestId: requestId
        )
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

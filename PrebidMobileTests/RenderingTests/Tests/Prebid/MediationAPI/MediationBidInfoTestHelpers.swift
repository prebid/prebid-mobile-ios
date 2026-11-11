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

/// Helpers shared by the Mediation API ad unit tests of `fetchDemandBidInfo`.
extension XCTestCase {

    /// Runs one `fetchDemandBidInfo` against a mocked Prebid Server that answers with `response`,
    /// and returns the `BidInfo` the ad unit reported on the main thread.
    /// - Parameter fetch: Starts the ad unit's fetch with the mocked connection and the completion.
    func fetchMediationBidInfo(
        response: PrebidServerResponse,
        fetch: (_ connection: PrebidServerConnectionProtocol, _ completion: @escaping (BidInfo) -> Void) -> Void
    ) -> BidInfo? {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(response)
        }])

        let asyncExpectation = expectation(description: "fetchDemandBidInfo executed")
        var result: BidInfo?

        fetch(connection) { bidInfo in
            XCTAssertTrue(Thread.isMainThread)
            result = bidInfo
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        return result
    }

    func assertWinningBidEconomics(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        // Values of `BidResponseTransformer.someValidResponse`
        XCTAssertEqual(bidInfo?.price?.doubleValue, 0.1091, file: file, line: line)
        XCTAssertEqual(bidInfo?.currency, "USD", file: file, line: line)
        XCTAssertEqual(bidInfo?.creativeId, "test-creative-id-1", file: file, line: line)
        XCTAssertEqual(bidInfo?.adId, "test-ad-id-12345", file: file, line: line)
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31", file: file, line: line)
    }

    /// Asserts that `bidInfo` carries nothing beyond its result code and request id, which is what a
    /// Mediation API ad unit reports when nothing reached the ad object.
    func assertNoBidAttached(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(bidInfo, file: file, line: line)
        XCTAssertNil(bidInfo?.targetingKeywords, file: file, line: line)
        XCTAssertNil(bidInfo?.nativeAdCacheId, file: file, line: line)
        XCTAssertNil(bidInfo?.exp, file: file, line: line)
        XCTAssertEqual(bidInfo?.events, [:], file: file, line: line)
        XCTAssertEqual(bidInfo?.topBidFiltered, false, file: file, line: line)
        XCTAssertNil(bidInfo?.price, file: file, line: line)
        XCTAssertNil(bidInfo?.currency, file: file, line: line)
        XCTAssertNil(bidInfo?.creativeId, file: file, line: line)
        XCTAssertNil(bidInfo?.adId, file: file, line: line)
    }
}

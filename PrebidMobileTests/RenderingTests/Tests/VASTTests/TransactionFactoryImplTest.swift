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

// `TransactionFactoryImpl` decides between the VAST and HTML factories by looking for "<VAST" in the markup.
// Unparseable VAST fails with "VAST Parsing failed", which the HTML factory never reports, so that error shows the branch taken.
class TransactionFactoryImplTest: XCTestCase {

    private func loadAndWaitForError(adMarkup: String) -> Error? {
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id")
        let adConfiguration = AdUnitConfig(configId: "config-id")
        let connection = UtilitiesForTesting.createConnectionForMockedTest()

        var reportedError: Error?
        let callbackCalled = expectation(description: "callback called")
        let factory = TransactionFactoryImpl(bid: bid, adConfiguration: adConfiguration, connection: connection) { _, error in
            reportedError = error
            callbackCalled.fulfill()
        }

        XCTAssertTrue(factory.load(adMarkup: adMarkup))
        waitForExpectations(timeout: 2)
        return reportedError
    }

    private func message(of error: Error?) -> String {
        (error as? PBMError)?.message ?? "\(String(describing: error))"
    }

    func testMarkupWithVastTagTakesTheVastBranch() {
        let error = loadAndWaitForError(adMarkup: "<VAST version=\"3.0\"><unclosed>")

        XCTAssertTrue(message(of: error).contains("VAST Parsing failed"), message(of: error))
    }

    // `-containsString:` (and so `NSString.contains`) matches "<VAST" when a zero-width joiner follows it; Swift `String.contains` does not.
    func testMarkupWithGraphemeExtenderAfterVastTagStillTakesTheVastBranch() {
        let error = loadAndWaitForError(adMarkup: "<VAST\u{200D}>")

        XCTAssertTrue(message(of: error).contains("VAST Parsing failed"), message(of: error))
    }

    func testSecondLoadWhileLoadingIsRejected() {
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id")
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        let factory = TransactionFactoryImpl(bid: bid, adConfiguration: AdUnitConfig(configId: "config-id"), connection: connection) { _, _ in }

        XCTAssertTrue(factory.load(adMarkup: "<VAST version=\"3.0\"><unclosed>"))
        XCTAssertFalse(factory.load(adMarkup: "<VAST version=\"3.0\"><unclosed>"))
    }
}

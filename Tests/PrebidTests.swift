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

class PrebidTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAccountId() {
        Prebid.shared.prebidServerAccountId = "123"
        XCTAssertEqual(Prebid.shared.prebidServerAccountId, "123")
        XCTAssertNotEqual(Prebid.shared.prebidServerAccountId, "456")
    }

    func testShareGeoLocation() {
        Prebid.shared.shareGeoLocation = true
        XCTAssertTrue(Prebid.shared.shareGeoLocation)

        Prebid.shared.shareGeoLocation = false
        XCTAssertFalse(Prebid.shared.shareGeoLocation)
    }

    func testServerHost() {
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        XCTAssertEqual(Prebid.shared.prebidServerHost, PrebidHost.Appnexus)

        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        XCTAssertEqual(Prebid.shared.prebidServerHost, PrebidHost.Rubicon)
    }

    func testServerCustomHost() {

        Prebid.shared.prebidServerHost = PrebidHost.Custom
        XCTAssertEqual(Prebid.shared.prebidServerHost, PrebidHost.Custom)

        XCTAssertThrowsError(try Prebid.shared.setCustomPrebidServer(url: "http://www.rubicon.org"))

        XCTAssertThrowsError(try Prebid.shared.setCustomPrebidServer(url: "abc"))
    }

    func testStoredAuctionResponse() {
        Prebid.shared.storedAuctionResponse = "111122223333"
        XCTAssertEqual(Prebid.shared.storedAuctionResponse, "111122223333")
    }
    
    func testStoredBidResponses() {
        Prebid.shared.addStoredBidResponse(bidder: "appnexus", responseId: "221144")
        Prebid.shared.addStoredBidResponse(bidder: "rubicon", responseId: "221155")
        XCTAssertFalse(Prebid.shared.storedBidResponses.isEmpty)
        Prebid.shared.clearStoredBidResponses()
        XCTAssertTrue(Prebid.shared.storedBidResponses.isEmpty)
    }
}

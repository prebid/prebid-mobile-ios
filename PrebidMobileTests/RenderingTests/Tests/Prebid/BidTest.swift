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

@testable import PrebidMobile

class BidTest: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Prebid.reset()
    }

    // Rendering API doesn't require cache id by default.
    // But publisher can set useCacheForReportingWithRenderingAPI to true
    // in order to add hb_cache_id to winning bid markers.
    func testWinningBidRendering() {
        let rawBid = RawWinningBidFabricator.makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: nil)
        let bid = Bid(bid: rawBid)
        XCTAssertTrue(bid.isWinning)
    }
    
    func testNoWinningBidRendering() {
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
        let rawBid = RawWinningBidFabricator.makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: nil)
        let bid = Bid(bid: rawBid)
        XCTAssertFalse(bid.isWinning)
    }
}

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
    
    func testWinningBidMarkers_hb_pb_noWinningBid() {
        let bid = RawWinningBidFabricator.makeWinningBid(price: nil, bidder: "some bidder", cacheID: nil)
        XCTAssertFalse(bid.isWinning)
    }
    
    func testWinningBidMarkers_hb_bidder_noWinningBid() {
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: nil, cacheID: nil)
        XCTAssertFalse(bid.isWinning)
    }

    // Rendering API doesn't require cache id by default.
    // But publisher can set useCacheForReportingWithRenderingAPI to true
    // in order to add hb_cache_id to winning bid markers.
    func testWinningBid_without_hb_cache_id() {
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: "some bidder", cacheID: nil)
        XCTAssertTrue(bid.isWinning)
    }
    
    func testNoWinningBid_hb_cache_id() {
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: "some bidder", cacheID: nil)
        XCTAssertFalse(bid.isWinning)
    }
    
    func testWinningBid_with_hb_cache_id() {
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: "some bidder", cacheID: "cache/id")
        XCTAssertTrue(bid.isWinning)
    }
    
    // No hb_cache_id = no winning bid in Original API
    func testWinningBidMarkers_NoWinningBid_OriginalApi() {
        let _ = AdUnit(configId: "configID", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: "some bidder", cacheID: nil)
        XCTAssertFalse(bid.isWinning)
    }
    
    func testWinningBidMarkers_WinningBid_OriginalApi() {
        let _ = AdUnit(configId: "configID", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        
        let bid = RawWinningBidFabricator.makeWinningBid(price: 0.75, bidder: "some bidder", cacheID: "cache/id")
        XCTAssertTrue(bid.isWinning)
    }
}

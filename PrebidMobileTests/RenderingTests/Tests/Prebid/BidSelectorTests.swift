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

@testable import PrebidMobile

private final class StubBidSelector: PrebidBidSelecting {
    private let selection: ([Bid]) -> Bid?

    init(_ selection: @escaping ([Bid]) -> Bid?) {
        self.selection = selection
    }

    func selectBid(from bids: [Bid]) -> Bid? {
        selection(bids)
    }
}

class BidSelectorTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Targeting.shared.forceSdkToChooseWinner = false
        Prebid.reset()
    }

    // MARK: - Characterization: default (no selector) behavior is unchanged

    func testNoSelectorByDefault_defaultMarkerLogicPicksWinner() {
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil)
        ])

        XCTAssertNil(bidResponse.bidSelector)
        XCTAssertNotNil(bidResponse.winningBid)
        XCTAssertEqual(bidResponse.winningBid?.targetingInfo?["hb_bidder"], "openx")
    }

    func testNoSelectorByDefault_unmarkedBidDoesNotWin() {
        // A bid with no hb_pb/hb_bidder markers is not treated as winning by the
        // SDK's default logic, even if its price is higher -- this must remain true
        // when bidSelector is nil.
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        XCTAssertNil(bidResponse.bidSelector)
        XCTAssertNil(bidResponse.winningBid)
    }

    // MARK: - New behavior: selector overrides default marker-driven winner

    func testSelectorOverridesDefaultWinner() {
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil),
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        // Default: the marker-driven bid wins, even though it's not the highest price.
        XCTAssertEqual(bidResponse.winningBid?.targetingInfo?["hb_bidder"], "openx")

        // Selector: always prefer the highest-price bid, regardless of markers.
        let selector = StubBidSelector { bids in bids.max { $0.price < $1.price } }
        bidResponse.applyBidSelector(selector)

        XCTAssertTrue(bidResponse.bidSelector === selector)
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)
    }

    func testSelectorReturningNil_resultsInNoWinningBid() {
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil)
        ])

        bidResponse.applyBidSelector(StubBidSelector { _ in nil })

        XCTAssertNil(bidResponse.winningBid)
    }

    func testApplyBidSelectorNil_restoresDefaultMarkerLogic() {
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil),
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        bidResponse.applyBidSelector(StubBidSelector { bids in bids.max { $0.price < $1.price } })
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)

        bidResponse.applyBidSelector(nil)

        XCTAssertNil(bidResponse.bidSelector)
        XCTAssertEqual(bidResponse.winningBid?.targetingInfo?["hb_bidder"], "openx")
    }

    // MARK: - Selector takes precedence over Targeting.forceSdkToChooseWinner

    func testSelectorTakesPrecedenceOverForceSdkToChooseWinner() {
        Targeting.shared.forceSdkToChooseWinner = true

        // No bid carries the full marker set, so default logic would report `.prebidDemandNoBids`
        // via `AdUnit.setUp` once `forceSdkToChooseWinner` is true. A selector should still be
        // able to pick a winner regardless of that flag.
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        bidResponse.applyBidSelector(StubBidSelector { bids in bids.first })

        XCTAssertNotNil(bidResponse.winningBid)
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)
    }

    // MARK: - Selector is consulted again after cache filtering, not bypassed

    func testSelectorConsultedAgainAfterRemoveBidsWithoutSuccessfulCache() {
        let cache: [String: Any] = ["bids": ["url": "https://prebid-cache/cache?uuid=cache-id", "cacheId": "cache-id"]]

        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: cache),
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: cache)
        ])

        let selector = StubBidSelector { bids in bids.max { $0.price < $1.price } }
        bidResponse.applyBidSelector(selector)
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)

        // Both bids have a successful server cache entry, so neither is removed here --
        // what matters is that recomputation after filtering still goes through the
        // selector rather than silently reverting to default marker-driven selection.
        let removed = bidResponse.removeBidsWithoutSuccessfulCache()

        XCTAssertEqual(removed, 0)
        XCTAssertTrue(bidResponse.bidSelector === selector)
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)
    }

    func testSelectorConsultedAgainAfterRemoveBidsWithoutSuccessfulCache_bidRemoved() {
        let cache: [String: Any] = ["bids": ["url": "https://prebid-cache/cache?uuid=cache-id", "cacheId": "cache-id"]]

        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: cache),
            // This bid has no cache entry and will be filtered out by removeBidsWithoutSuccessfulCache().
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        let selector = StubBidSelector { bids in bids.max { $0.price < $1.price } }
        bidResponse.applyBidSelector(selector)
        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)

        _ = bidResponse.removeBidsWithoutSuccessfulCache()

        // The higher-price bid is gone; the selector -- still active -- now falls back to
        // the remaining marker-driven bid, proving it was re-invoked with the filtered set
        // rather than the response silently keeping the old (now-removed) winner.
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertEqual(bidResponse.winningBid?.price, 0.75)
        XCTAssertEqual(bidResponse.winningBid?.targetingInfo?["hb_bidder"], "openx")
    }

    // MARK: - Selector must not leave stale winner-marker keys in targetingInfo

    func testSelectorPickingUnmarkedBid_doesNotLeakOldWinnerMarkers() {
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil),
            Self.bidDictionary(id: "unmarked", price: 2.00, bidder: nil, cache: nil)
        ])

        // Selector picks the unmarked bid, which has no targetingInfo of its own.
        let selector = StubBidSelector { bids in bids.max { $0.price < $1.price } }
        bidResponse.applyBidSelector(selector)

        XCTAssertEqual(bidResponse.winningBid?.price, 2.00)
        // The "marked" bid is no longer the winner -- its hb_bidder/hb_pb markers must not
        // survive into the merged targetingInfo, or the ad server would be targeted with a
        // different bid than the one `winningBid` actually reports.
        XCTAssertNil(bidResponse.targetingInfo?["hb_bidder"])
        XCTAssertNil(bidResponse.targetingInfo?["hb_pb"])
    }

    func testDefaultLogic_stillReportsWinnerMarkers() {
        // Characterization: when no selector is active, the actual winner's own markers
        // must still flow through untouched -- the leak fix only strips markers from bids
        // that are *not* the winner.
        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil)
        ])

        XCTAssertEqual(bidResponse.targetingInfo?["hb_bidder"], "openx")
        XCTAssertEqual(bidResponse.targetingInfo?["hb_pb"], "0.75")
    }

    // MARK: - Selector must not be able to hand back a bid that isn't in the provided array

    func testSelectorReturningForeignBid_isRejected() {
        // A bid from an entirely separate response -- e.g. one a publisher's selector
        // implementation retained from a previous auction -- must never become the winner.
        let staleResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "stale", price: 5.00, bidder: "stale_bidder", cache: nil)
        ])
        let staleBid = staleResponse.allBids![0]

        let bidResponse = Self.makeBidResponse([
            Self.bidDictionary(id: "marked", price: 0.75, bidder: "openx", cache: nil)
        ])

        bidResponse.applyBidSelector(StubBidSelector { _ in staleBid })

        XCTAssertNil(bidResponse.winningBid)
        XCTAssertNil(bidResponse.targetingInfo?["hb_bidder"])
    }

    // MARK: - Helpers

    private static func makeBidResponse(_ bidDictionaries: [[String: Any]]) -> BidResponse {
        BidResponse(jsonDictionary: [
            "id": "response-id",
            "seatbid": [
                [
                    "bid": bidDictionaries,
                    "seat": "openx"
                ]
            ],
            "cur": "USD"
        ])
    }

    private static func bidDictionary(
        id: String,
        price: Double,
        bidder: String?,
        cache: [String: Any]?
    ) -> [String: Any] {
        var prebid: [String: Any] = ["type": "banner"]

        if let bidder {
            prebid["targeting"] = [
                "hb_bidder": bidder,
                "hb_pb": "\(NSString(format: "%4.2f", price))"
            ]
        }

        if let cache {
            prebid["cache"] = cache
        }

        return [
            "id": "test-bid-id-\(id)",
            "impid": "test-imp-id-\(id)",
            "price": price,
            "adm": "<html></html>",
            "w": 300,
            "h": 250,
            "ext": ["prebid": prebid]
        ]
    }
}

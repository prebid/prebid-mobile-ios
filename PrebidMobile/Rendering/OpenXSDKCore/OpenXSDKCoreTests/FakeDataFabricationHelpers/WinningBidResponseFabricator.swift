//
//  WinningBidResponseFabricator.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import Foundation
import XCTest

protocol WinningBidResponseFabricator: RawWinningBidFabricator {
    // see extension below
}

extension WinningBidResponseFabricator {
    func makeWinningBidResponse(bidPrice: Double) -> OXABidResponse {
        let rawBidResponse = OXMORTBBidResponse<OXAORTBBidResponseExt, NSDictionary, OXAORTBBidExt>()
        rawBidResponse.seatbid = [.init()]
        let rawWinningBid = makeRawWinningBid(price: bidPrice, bidder: "some bidder", cacheID: "some-cache-id")
        rawBidResponse.seatbid![0].bid = [rawWinningBid]
        let bidResponse = OXABidResponse(rawBidResponse: rawBidResponse)
        XCTAssertNotNil(bidResponse.winningBid)
        return bidResponse
    }
}

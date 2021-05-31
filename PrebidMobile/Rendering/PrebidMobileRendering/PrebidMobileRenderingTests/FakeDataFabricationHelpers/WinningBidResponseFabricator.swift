//
//  WinningBidResponseFabricator.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

protocol WinningBidResponseFabricator: RawWinningBidFabricator {
    // see extension below
}

extension WinningBidResponseFabricator {
    func makeWinningBidResponse(bidPrice: Double) -> BidResponse {
        let rawBidResponse = PBMORTBBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>()
        rawBidResponse.seatbid = [.init()]
        let rawWinningBid = makeRawWinningBid(price: bidPrice, bidder: "some bidder", cacheID: "some-cache-id")
        rawBidResponse.seatbid![0].bid = [rawWinningBid]
        let bidResponse = BidResponse(jsonDictionary: rawBidResponse.toJsonDictionary() as NSDictionary)
        XCTAssertNotNil(bidResponse.winningBid)
        return bidResponse
    }
}

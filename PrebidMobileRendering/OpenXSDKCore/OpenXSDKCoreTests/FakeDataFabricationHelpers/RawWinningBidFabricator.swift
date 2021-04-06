//
//  RawWinningBidFabricator.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import Foundation

protocol RawWinningBidFabricator {
    // see extension below
}

extension RawWinningBidFabricator {
    func makeRawWinningBid(price: Double, bidder: String, cacheID: String) -> OXMORTBBid<OXAORTBBidExt> {
        let rawBid = OXMORTBBid<OXAORTBBidExt>()
        rawBid.price = NSNumber(value: price)
        rawBid.ext = .init()
        rawBid.ext.prebid = .init()
        rawBid.ext.prebid?.targeting = [
            "hb_pb": "\(NSString(format: "%4.2f", price))",
            "hb_bidder": bidder,
            "hb_cache_id": cacheID,
        ]
        return rawBid
    }
}

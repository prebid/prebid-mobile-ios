//
//  RawSampleCustomRendererBidFabricator.swift
//  PrebidMobileTests
//
//  Created by Richard Dépierre on 24/07/2024.
//  Copyright © 2024 AppNexus. All rights reserved.
//

import Foundation

@testable @_spi(PBMInternal) import PrebidMobile

public class RawSampleCustomRendererBidFabricator {
    static func makeSampleCustomRendererBid(
        rendererName: String,
        rendererVersion: String
    ) -> ORTBBid<ORTBBidExt> {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "", impid: "", price: 1.2)
        rawBid.ext = .init()
        rawBid.ext?.prebid = .init()
        
        rawBid.ext?.prebid?.targeting = [
            "hb_pb": "1.2"
        ]
        rawBid.ext?.prebid?.targeting?["hb_bidder"] = "appnexus"
        rawBid.ext?.prebid?.targeting?["hb_cache_id"] = "cacheid"
        rawBid.ext?.prebid?.type = "banner"
        rawBid.ext?.prebid?.meta = [
            Bid.KEY_RENDERER_NAME: rendererName,
            Bid.KEY_RENDERER_VERSION: rendererVersion
        ]
        return rawBid
    }
}

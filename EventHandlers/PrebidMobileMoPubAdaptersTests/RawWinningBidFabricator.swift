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

import Foundation
import PrebidMobile

protocol RawWinningBidFabricator {
    // see extension below
}

extension RawWinningBidFabricator {
    func makeRawWinningBidRendering(price: Double, bidder: String, cacheID: String) -> PBMORTBBid<PBMORTBBidExt> {
        let rawBid = PBMORTBBid<PBMORTBBidExt>()
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
    
    func makeRawWinningBidOriginal(price: Double, bidder: String, cacheID: String) -> BidResponse {
        let prebidKeywords: [String: String] = [
            "hb_env": "mobile-app",
            "hb_bidder": bidder,
            "hb_size": "300x250",
            "hb_pb": String(price),
            "hb_env": "mobile-app",
            "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
            "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
            "hb_pb": "0.50",
            "hb_size": "300x250",
            "hb_cache_id_local": cacheID
        ]
        
        return BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])
    }
}

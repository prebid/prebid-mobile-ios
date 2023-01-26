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

public class RawWinningBidFabricator {
    static func makeRawWinningBid(price: Double?, bidder: String?, cacheID: String?) -> PBMORTBBid<PBMORTBBidExt> {
        let rawBid = PBMORTBBid<PBMORTBBidExt>()
        rawBid.ext = .init()
        rawBid.ext.prebid = .init()
      
        if let price = price {
            rawBid.price = NSNumber(value: price)
            
            rawBid.ext.prebid?.targeting = [
                "hb_pb": "\(NSString(format: "%4.2f", price))"
            ]
        }
        
        rawBid.ext.prebid?.targeting?["hb_bidder"] = bidder
        rawBid.ext.prebid?.targeting?["hb_cache_id"] = cacheID
        return rawBid
    }
    
    static func makeWinningBid(price: Double?, bidder: String?, cacheID: String?) -> Bid {
        let rawBid = makeRawWinningBid(price: price, bidder: bidder, cacheID: cacheID)
        
        return Bid(bid: rawBid)
    }
}

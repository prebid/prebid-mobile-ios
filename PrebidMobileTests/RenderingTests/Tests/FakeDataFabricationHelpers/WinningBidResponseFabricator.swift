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
import XCTest

@testable import PrebidMobile

public class WinningBidResponseFabricator {
    static func makeWinningBidResponse(bidPrice: Double) -> BidResponse {
        let rawWinningBid = RawWinningBidFabricator.makeRawWinningBid(price: bidPrice, bidder: "some bidder", cacheID: "some-cache-id")
        
        let rawBidResponse = ORTBBidResponse<ORTBBidResponseExt, [String : Any], ORTBBidExt>(
            requestID: ""
        )
        rawBidResponse.seatbid = [.init(bid: [rawWinningBid])]
        
        let bidResponse = BidResponse(jsonDictionary: rawBidResponse.jsonDictionary)
        XCTAssertNotNil(bidResponse.winningBid)
        return bidResponse
    }
}

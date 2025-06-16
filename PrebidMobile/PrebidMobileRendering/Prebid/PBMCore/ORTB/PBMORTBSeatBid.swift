//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

// 4.2.2: SeatBid

/// A bid response can contain multiple `SeatBid` objects, each on behalf of a different bidder seat and each containing
/// one or more individual bids. If multiple impressions are presented in the request, the `group` attribute can be used to
/// specify if a seat is willing to accept any impressions that it can win (default) or if it is only interested in
/// winning any if it can win them all as a group.
class PBMORTBSeatBid<
    ExtType: PBMJsonCodable,
    BidExtType: PBMJsonCodable
>: PBMJsonCodable, PBMORTBExtensible {
    
    /// [Required]
    /// Array of 1+ `Bid` objects (Section 4.2.3) each related to an impression. Multiple bids can relate to the same impression.
    var bid: [PBMORTBBid<BidExtType>]
    
    /// ID of the buyer seat (e.g., advertiser, agency) on whose behalf this bid is made.
    var seat: String?
    
    /// [Integer]
    /// [Default = 0]
    /// 0 = impressions can be won individually; 1 = impressions must be won or lost as a group.
    var group: NSNumber?
    
    /// Placeholder for bidder-specific extensions to OpenRTB.
    var ext: ExtType?
    
    private enum KeySet: String {
        case bid
        case seat
        case group
        case ext
    }
    
    init(bid: [PBMORTBBid<BidExtType>]) {
        self.bid = bid
    }
    
    required init?(jsonDictionary: [String : Any]) {
        // TODO: assert or inject dummy bid ext parser?
        return nil
    }
    
    required init?(jsonDictionary: [String : Any], extParser: ([String : Any]) -> ExtType?) {
        // TODO: assert or inject dummy bid ext parser?
        return nil
    }
    
    required convenience init?(jsonDictionary: [String : Any],
                   extParser: ([String : Any]) -> ExtType?,
                   bidExtParser: ([String : Any]) -> BidExtType?) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        guard let bidsArray: [[String : Any]] = json[.bid] else {
            return nil
        }
        let bids = bidsArray.compactMap {
            PBMORTBBid(jsonDictionary: $0, extParser: bidExtParser)
        }
        guard !bids.isEmpty else {
            return nil
        }
        
        self.init(bid: bids)
        
        seat    = json[.seat]
        group   = json[.group]
        ext     = json[.ext]
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.bid]      = bid
        json[.seat]     = seat
        json[.group]    = group
        json[.ext]      = ext
        
        return json.dict
    }
}

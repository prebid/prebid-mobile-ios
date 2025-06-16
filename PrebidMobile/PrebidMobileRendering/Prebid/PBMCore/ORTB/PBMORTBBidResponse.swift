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

// 4.2.1: BidResponse

/// This object is the top-level bid response object (i.e., the unnamed outer JSON object). The `id` attribute is
/// a reflection of the bid request ID for logging purposes. Similarly, `bidid` is an optional response tracking ID for
/// bidders. If specified, it can be included in the subsequent win notice call if the bidder wins. At least one `seatbid`
/// object is required, which contains at least one bid for an impression. Other attributes are optional.
///
/// To express a “no-bid”, the options are to return an empty response with HTTP 204. Alternately if the bidder wishes to
/// convey to the exchange a reason for not bidding, just a `BidResponse` object is returned with a reason code in the `nbr`
/// attribute.
class PBMORTBBidResponse<
    ExtType: PBMJsonCodable,
    SeatBidExtType: PBMJsonCodable,
    BidExtType: PBMJsonCodable
>: PBMJsonCodable, PBMORTBExtensible {
    
    /// [Required]
    /// ID of the bid request to which this is a response.
    var requestID: String
    
    /// Array of seatbid objects; 1+ required if a bid is to be made.
    var seatbid: [PBMORTBSeatBid<SeatBidExtType, BidExtType>]?
    
    /// Bidder generated response ID to assist with logging/tracking.
    var bidid: String?
    
    /// [Default = “USD”]
    /// Bid currency using ISO-4217 alpha codes.
    var cur: String?
    
    /// Optional feature to allow a bidder to set data in the exchange’s cookie.
    /// The string must be in base85 cookie safe characters and be in any format.
    /// Proper JSON encoding must be used to include “escaped” quotation marks.
    var customdata: String?
    
    /// [Integer]
    /// Reason for not bidding. See `PBMORTBNoBidReason`
    var nbr: NSNumber?
    
    /// Placeholder for bidder-specific extensions to OpenRTB.
    var ext: ExtType?
    
    private enum KeySet: String {
        case id
        case seatbid
        case bidid
        case cur
        case customdata
        case nbr
        case ext
    }
    
    init(requestID: String) {
        self.requestID = requestID
    }
    
    convenience required init?(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        guard let requestID: String = json[.id]
        else {
            return nil
        }
        
        self.init(requestID: requestID)
        
        bidid       = json[.bidid]
        cur         = json[.cur]
        customdata  = json[.customdata]
        nbr         = json[.nbr]
    }
    
    required convenience init?(jsonDictionary: [String : Any], extParser: ([String : Any]) -> ExtType?) {
        self.init(jsonDictionary: jsonDictionary)
        
        let json = JSONObject<KeySet>(jsonDictionary)
        ext = json[.ext]
    }
    
    convenience init?(jsonDictionary: [String : Any],
                      extParser: ([String : Any]) -> ExtType?,
                      seatBidExtParser: ([String : Any]) -> SeatBidExtType?,
                      bidExtParser: ([String : Any]) -> BidExtType?) {
        self.init(jsonDictionary: jsonDictionary, extParser: extParser)
        
        
        let json = JSONObject<KeySet>(jsonDictionary)
        
        if let seatBidArray: [[String : Any]] = json[.seatbid] {
            seatbid = seatBidArray.compactMap {
                PBMORTBSeatBid(jsonDictionary: $0,
                                      extParser: seatBidExtParser,
                                      bidExtParser: bidExtParser)
            }
        }
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.id]           = requestID
        json[.seatbid]      = seatbid
        json[.bidid]        = bidid
        json[.cur]          = cur
        json[.customdata]   = customdata
        json[.nbr]          = nbr
        json[.ext]          = ext
        
        return json.dict
    }
}

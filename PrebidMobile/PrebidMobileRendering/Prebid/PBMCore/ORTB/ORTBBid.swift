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

/// A SeatBid object contains one or more `Bid` objects, each of which relates to a specific impression in the bid
/// request via the `impid` attribute and constitutes an offer to buy that impression for a given `price`.
class ORTBBid<ExtType: PBMJsonCodable>: PBMJsonCodable, PBMORTBExtensible {
    /// [Required]
    /// Bidder generated bid ID to assist with logging/tracking.
    var bidID: String?
    
    /// [Required]
    /// ID of the Imp object in the related bid request.
    var impid: String?
    
    /// [Required]
    /// [Float]
    /// Bid price expressed as CPM although the actual transaction is for a unit impression only. Note that while the type
    /// indicates float, integer math is highly recommended when handling currencies (e.g., BigDecimal in Java).
    var price: NSNumber?
    
    /// Win notice URL called by the exchange if the bid wins (not necessarily indicative of a delivered, viewed, or
    /// billable ad); optional means of serving ad markup. Substitution macros (Section 4.4) may be included in both the URL
    /// and optionally returned markup.
    var nurl: String?
    
    /// Billing notice URL called by the exchange when a winning bid becomes billable based on exchange-specific business
    /// policy (e.g., typically delivered, viewed, etc.). Substitution macros (Section 4.4) may be included.
    var burl: String?
    
    /// Loss notice URL called by the exchange when a bid is known to have been lost. Substitution macros (Section 4.4)
    /// may be included. Exchange-specific policy may preclude support for loss notices or the disclosure of winning
    /// clearing prices resulting in ${AUCTION_PRICE} macros being removed (i.e., replaced with a zero-length string).
    var lurl: String?
    
    /// Optional means of conveying ad markup in case the bid wins; supersedes the win notice if markup is included in both.
    /// Substitution macros (Section 4.4) may be included.
    var adm: String?
    
    /// ID of a preloaded ad to be served if the bid wins.
    var adid: String?
    
    /// Advertiser domain for block list checking (e.g., “ford.com”). This can be an array of for the case of rotating
    /// creatives. Exchanges can mandate that only one domain is allowed.
    var adomain: [String]?
    
    /// A platform-specific application identifier intended to be unique to the app and independent of the exchange.
    /// On Android, this should be a bundle or package name (e.g., com.foo.mygame).
    /// On iOS, it is a numeric ID.
    var bundle: String?
    
    /// URL without cache-busting to an image that is representative of the content of the campaign for ad quality/safety
    /// checking.
    var iurl: String?
    
    /// Campaign ID to assist with ad quality checking; the collection of creatives for which iurl should be representative.
    var cid: String?
    
    /// Creative ID to assist with ad quality checking.
    var crid: String?
    
    /// Tactic ID to enable buyers to label bids for reporting to the exchange the tactic through which their bid was submitted.
    /// The specific usage and meaning of the tactic ID should be communicated between buyer and exchanges _a priori_.
    var tactic: String?
    
    /// IAB content categories of the creative. Refer to List 5.1.
    var cat: [String]?
    
    /// [Integer array]
    /// Set of attributes describing the creative. Refer to List 5.3.
    var attr: [NSNumber]?
    
    /// [Integer]
    /// API required by the markup if applicable. Refer to List 5.6.
    var api: NSNumber?
    
    /// [Integer]
    /// Video response protocol of the markup if applicable. Refer to List 5.8.
    var `protocol`: NSNumber?
    
    /// [Integer]
    /// Creative media rating per IQG guidelines. Refer to List 5.19.
    var qagmediarating: NSNumber?
    
    /// Language of the creative using ISO-639-1-alpha-2. The non- standard code “xx” may also be used if the creative has no
    /// linguistic content (e.g., a banner with just a company logo).
    var language: String?
    
    /// Reference to the `deal.id` from the bid request if this bid pertains to a private marketplace direct deal.
    var dealid: String?
    
    /// [Integer]
    /// Width of the creative in device independent pixels (DIPS).
    var w: NSNumber?
    
    /// [Integer]
    /// Height of the creative in device independent pixels (DIPS).
    var h: NSNumber?
    
    /// [Integer]
    /// Relative width of the creative when expressing size as a ratio. Required for Flex Ads.
    var wratio: NSNumber?
    
    /// [Integer]
    /// Relative height of the creative when expressing size as a ratio. Required for Flex Ads.
    var hratio: NSNumber?
    
    /// [Integer]
    /// Advisory as to the number of seconds the bidder is willing to wait between the auction and the actual impression.
    var exp: NSNumber?
    
    /// Placeholder for bidder-specific extensions to OpenRTB.
    var ext: ExtType?
    
    private enum KeySet: String {
        case id
        case impid
        case price
        case nurl
        case burl
        case lurl
        case adm
        case adid
        case adomain
        case bundle
        case iurl
        case cid
        case crid
        case tactic
        case cat
        case attr
        case api
        case `protocol`
        case qagmediarating
        case language
        case dealid
        case w
        case h
        case wratio
        case hratio
        case exp
        case ext
    }
    
    init(bidID: String, impid: String, price: NSNumber) {
        self.bidID = bidID
        self.impid = impid
        self.price = price
    }
    
    public required convenience init?(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        guard let id: String = json[.id],
              let impid: String = json[.impid],
              let price: NSNumber = json[.price]
        else {
            return nil
        }
        
        self.init(bidID: id, impid: impid, price: price)
        
        nurl        = json[.nurl]
        burl        = json[.burl]
        lurl        = json[.lurl]
        adm         = json[.adm]
        adid        = json[.adid]
        adomain     = json[.adomain]
        bundle      = json[.bundle]
        iurl        = json[.iurl]
        cid         = json[.cid]
        crid        = json[.crid]
        tactic      = json[.tactic]
        cat         = json[.cat]
        attr        = json[.attr]
        api         = json[.api]
        `protocol`  = json[.protocol]
        qagmediarating = json[.qagmediarating]
        language    = json[.language]
        dealid      = json[.dealid]
        w           = json[.w]
        h           = json[.h]
        wratio      = json[.wratio]
        hratio      = json[.hratio]
        exp         = json[.exp]
    }
    
    required convenience init?(jsonDictionary: [String : Any], extParser: ([String : Any]) -> ExtType?) {
        self.init(jsonDictionary: jsonDictionary)
        
        let json = JSONObject<KeySet>(jsonDictionary)
        ext = json[.ext]
    }
    
    public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.id]           = bidID
        json[.impid]        = impid
        json[.price]        = price
        
        json[.nurl]         = nurl
        json[.burl]         = burl
        json[.lurl]         = lurl
        json[.adm]          = adm
        json[.adid]         = adid
        json[.adomain]      = adomain
        json[.bundle]       = bundle
        json[.iurl]         = iurl
        json[.cid]          = cid
        json[.crid]         = crid
        json[.tactic]       = tactic
        json[.cat]          = cat
        json[.attr]         = attr
        json[.api]          = api
        json[.protocol]     = `protocol`
        json[.qagmediarating] = qagmediarating
        json[.language]     = language
        json[.dealid]       = dealid
        json[.w]            = w
        json[.h]            = h
        json[.wratio]       = wratio
        json[.hratio]       = hratio
        json[.exp]          = exp
        json[.ext]          = ext
        
        return json.dict
    }
}

/*   Copyright 2019-2023 Prebid.org, Inc.

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

/// Contains information about bid.
@objcMembers
@objc(PBMBidInfo)
public class BidInfo: NSObject {
    
    /// Key to get Prebid win event from `events`
    public static let EVENT_WIN = "ext.prebid.events.win"
    
    /// Key to get Prebid imp event from `events`
    public static let EVENT_IMP = "ext.prebid.events.imp"
  
    /// The result code of the bid request
    public private(set) var resultCode: ResultCode
    
    /// Targeting keywords associated with the bid
    public private(set) var targetingKeywords: [String: String]?
    
    /// The expiration time of the bid
    public private(set) var exp: Double?
    
    /// The cache ID for native ads
    public private(set) var nativeAdCacheId: String?
    
    /// Events related to the bid
    public private(set) var events: [String: String]

    /// True when `Prebid.shared.filterOutUncachedBids` removed the bid Prebid Server
    /// designated as the winner because it had no successful Prebid Cache entry, and a
    /// lower-priced cached bid was promoted in its place.
    ///
    /// The demand is still valid and its targeting is attached to the ad object, so
    /// `resultCode` remains `.prebidDemandFetchSuccess`. This flag exists purely so
    /// publishers can track the yield impact of the filtering.
    public private(set) var topBidFiltered: Bool

    // MARK: - Winning-bid economics
    // Exact economics of the bid whose targeting Prebid attached to the ad object, surfaced on the
    // original (GAM) API (Prebid normally exposes only the bucketed `hb_pb` keyword). These read the
    // bid's real values off the (module-internal) ORTB response inside `create(...)`.
    //
    // `cpm`, `currency`, `creativeId` and `adId` describe that bid and are `nil` unless a bid was
    // designated — a top bid without `hb_pb`/`hb_bidder`/`hb_cache_id` targeting is not one. When
    // `topBidFiltered` is true they describe the promoted cached runner-up (the bid actually
    // attached), not the server's original top bid. Do NOT read a nil `cpm` as a zero-price win.
    // `requestId` is response-level and is present whenever the response parsed.

    /// Net price (exact CPM) of the bid whose targeting was attached, or `nil` when none was designated.
    ///
    /// Typed `NSNumber?` (not `Double?`) so it is visible from Objective-C and carries the price
    /// exactly as Prebid Server sent it — reading it as a `Float` first (as `Bid.price` does) would
    /// round most decimal prices (e.g. `3.14` → `3.1400001…`).
    public private(set) var cpm: NSNumber?

    /// Currency (ISO-4217) for `cpm`. Defaults to `"USD"` — the ORTB default — when the response
    /// omits `cur`. `nil` when no bid was designated.
    public private(set) var currency: String?

    /// Creative id (`crid`) of the attached bid, or `nil` when none was designated.
    public private(set) var creativeId: String?

    /// The Prebid request id — the ORTB `BidResponse.id`, a per-request UUID the SDK generates for
    /// each bid request. It identifies this request, not an auction. `nil` if the response did not parse.
    public private(set) var requestId: String?

    /// Ad id (`adid`) of the attached bid, or `nil` when none was designated.
    public private(set) var adId: String?

    /// Initializes a new `BidInfo` instance with the specified parameters.
    /// - Parameters:
    ///   - resultCode: The result code of the bid request.
    ///   - targetingKeywords: Optional targeting keywords associated with the bid.
    ///   - exp: Optional expiration time of the bid.
    ///   - nativeAdCacheId: Optional cache ID for native ads.
    ///   - events: Optional dictionary of events related to the bid.
    ///   - topBidFiltered: Whether the PBS-designated winning bid was filtered out for
    ///   lacking a cache entry and a lower-priced cached bid was promoted in its place.
    ///   - cpm: Optional net price (exact CPM) of the attached bid.
    ///   - currency: Optional currency (ISO-4217) for `cpm`.
    ///   - creativeId: Optional creative id (`crid`) of the attached bid.
    ///   - adId: Optional ad id (`adid`) of the attached bid.
    ///   - requestId: Optional Prebid request id (ORTB `BidResponse.id`).
    public init(resultCode: ResultCode, targetingKeywords: [String : String]? = nil, exp: Double? = nil,
                nativeAdCacheId: String? = nil, events: [String: String] = [:],
                topBidFiltered: Bool = false,
                cpm: NSNumber? = nil, currency: String? = nil, creativeId: String? = nil,
                adId: String? = nil, requestId: String? = nil) {
        self.resultCode = resultCode
        self.targetingKeywords = targetingKeywords
        self.exp = exp
        self.nativeAdCacheId = nativeAdCacheId
        self.events = events
        self.topBidFiltered = topBidFiltered
        self.cpm = cpm
        self.currency = currency
        self.creativeId = creativeId
        self.adId = adId
        self.requestId = requestId

        super.init()
    }
    
    // Obj-C API
    /// Retrieves the expiration time of the bid as an `NSNumber`.
    public func getExp() -> NSNumber? {
        if let exp {
            return NSNumber(value: exp)
        } else {
            return nil
        }
    }
    
    // MARK: - Internal Zone
    
    static func create(resultCode: ResultCode, bidResponse: BidResponse) -> BidInfo {
        let bidInfo = BidInfo(
            resultCode: resultCode,
            targetingKeywords: bidResponse.targetingInfo,
            exp: bidResponse.winningBid?.bid.exp?.doubleValue,
            nativeAdCacheId: bidResponse.targetingInfo?[PrebidLocalCacheIdKey],
            topBidFiltered: bidResponse.topBidWasFiltered
        )
        
        if let winURL = bidResponse.winningBid?.events?.win {
            bidInfo.addEvent(key: BidInfo.EVENT_WIN, value: winURL)
        }
        
        if let impURL = bidResponse.winningBid?.events?.imp {
            bidInfo.addEvent(key: BidInfo.EVENT_IMP, value: impURL)
        }

        // Surface exact economics of the attached bid (original-API analytics). These read the
        // module-internal ORTB objects, only reachable here inside PrebidMobile, and stay nil unless
        // a bid was designated (when `topBidFiltered` is true this is the promoted cached runner-up).
        if let winningBid = bidResponse.winningBid {
            // Read the raw ORTB price (NSNumber) rather than the computed `Bid.price` Float, so the
            // value round-trips exactly and a missing price stays nil instead of becoming 0.0.
            bidInfo.cpm = winningBid.bid.price
            bidInfo.creativeId = winningBid.bid.crid
            bidInfo.adId = winningBid.bid.adid
            // ORTB defaults `cur` to "USD" when omitted; apply that so consumers needn't know the spec.
            bidInfo.currency = bidResponse.rawResponse?.cur ?? "USD"
        }

        // Response-level: the id of THIS bid request (ORTB `BidResponse.id`, an SDK-generated UUID).
        bidInfo.requestId = bidResponse.rawResponse?.requestID

        return bidInfo
    }
    
    func addEvent(key: String, value: String) {
        events[key] = value
    }
}

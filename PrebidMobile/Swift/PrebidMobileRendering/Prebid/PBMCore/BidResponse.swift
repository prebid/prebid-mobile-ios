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

typealias RawBidResponse = ORTBBidResponse<ORTBBidResponseExt, [String : Any], ORTBBidExt>

@objcMembers
public class BidResponse: NSObject {
    
    public var adUnitId: String?
    
    public private(set) var allBids: [Bid]?
    public private(set) var winningBid: Bid?
    public private(set) var targetingInfo: [String: String]?
    
    public private(set) var tmaxrequest: NSNumber?
    
    public private(set) var ext: ORTBBidResponseExt?

    /// The publisher-supplied bid selector currently in effect, if any. Set via `applyBidSelector(_:)`.
    public private(set) var bidSelector: PrebidBidSelecting?

    private(set) var rawResponse: RawBidResponse?
    
    public convenience init(adUnitId: String?, targetingInfo: [String: String]?) {
        self.init(jsonDictionary: [:])
        self.adUnitId = adUnitId
        self.targetingInfo = targetingInfo
    }

    public convenience init(jsonDictionary: [String : Any]) {
        let rawResponse = RawBidResponse(
            jsonDictionary: jsonDictionary,
            extParser: { extDic in
                ORTBBidResponseExt(jsonDictionary: extDic)
            },
            seatBidExtParser: { extDic in
                extDic
            },
            bidExtParser: { extDic in
                ORTBBidExt(jsonDictionary: extDic)
            })
        
        self.init(rawBidResponse: rawResponse)
    }
    
    required init(rawBidResponse: RawBidResponse?) {
        rawResponse = rawBidResponse
        super.init()
        
        guard let rawBidResponse = rawBidResponse else {
            return
        }

        var allBids: [Bid] = []
        if let seatbid = rawBidResponse.seatbid {
            for nextSeatBid in seatbid {
                guard let bids = nextSeatBid.bid else { continue }
                for nextBid in bids {
                    let bid = Bid(bid: nextBid)
                    allBids.append(bid)
                }
            }
        }

        self.allBids = allBids
        updateWinningBidAndTargetingInfo(from: allBids)
        tmaxrequest = rawBidResponse.ext?.tmaxrequest
        self.ext = rawBidResponse.ext
    }
    
    public func setTargetingInfo(with newValue: [String : String]) {
        targetingInfo = newValue
    }
    
    public func addTargetingInfoValue(key: String, value: String) {
        if targetingInfo == nil {
            targetingInfo = [:]
        }
        
        targetingInfo?[key] = value
    }
    
    @discardableResult
    public func removeBidsWithoutSuccessfulCache() -> Int {
        guard let allBids else { return 0 }
        
        let filteredBids = allBids.filter { $0.hasSuccessfulServerCache }
        let removedBids = allBids.count - filteredBids.count
        
        self.allBids = filteredBids
        updateWinningBidAndTargetingInfo(from: filteredBids)
        
        return removedBids
    }

    /// Sets the bid selector and immediately recomputes the winning bid and targeting info using it.
    /// When `selector` is non-nil, it takes precedence over the default marker-driven winner selection.
    /// - Parameter selector: The bid selector to apply, or `nil` to restore the default selection logic.
    public func applyBidSelector(_ selector: PrebidBidSelecting?) {
        bidSelector = selector
        updateWinningBidAndTargetingInfo(from: allBids ?? [])
    }

    /// Standard winner-marker keys (see `Bid.isWinning`). These specifically identify "the" winner,
    /// so they must never be attributed to a bid that isn't the (possibly selector-chosen) winner --
    /// otherwise `targetingInfo` could still point at a different bid than `winningBid` does.
    private static let winningBidMarkerKeys: Set<String> = ["hb_pb", "hb_bidder", "hb_cache_id"]

    private func updateWinningBidAndTargetingInfo(from bids: [Bid]) {
        var targetingInfo: [String : String] = [:]
        var winningBid: Bid?
        let selectorActive = bidSelector != nil

        if let bidSelector {
            let selectedBid = bidSelector.selectBid(from: bids)
            if let selectedBid, !bids.contains(where: { $0 === selectedBid }) {
                Log.warn("PrebidBidSelecting.selectBid(from:) returned a bid that is not part of the provided bids. Ignoring it.")
            } else {
                winningBid = selectedBid
            }
        } else {
            for bid in bids {
                if winningBid == nil && bid.isWinning {
                    winningBid = bid
                }
            }
        }

        for bid in bids {
            guard winningBid !== bid, let bidTargetingInfo = bid.targetingInfo else { continue }
            // Only strip the standard winner markers when a selector is actively overriding the
            // winner -- that's the one scenario where a bid other than `winningBid` could still
            // carry `hb_pb`/`hb_bidder`/`hb_cache_id` and mislead the ad server about who won.
            // In default (no-selector) mode, leave this untouched: a bid with only a partial
            // marker set (e.g. `hb_bidder` but no `hb_pb`) legitimately contributes it today.
            let nonWinnerTargetingInfo = selectorActive
                ? bidTargetingInfo.filter { !Self.winningBidMarkerKeys.contains($0.key) }
                : bidTargetingInfo
            targetingInfo.merge(nonWinnerTargetingInfo) { $1 }
        }

        if let winningBidTargetingInfo = winningBid?.targetingInfo {
            targetingInfo.merge(winningBidTargetingInfo) { $1 }
        }

        self.winningBid = winningBid
        self.targetingInfo = targetingInfo.isEmpty ? nil : targetingInfo
    }
}

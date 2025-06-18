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
        
        guard let rawBidResponse = rawBidResponse else {
            return
        }

        var allBids: [Bid] = []
        var targetingInfo: [String : String] = [:]
        var winningBid: Bid? = nil

        if let seatbid = rawBidResponse.seatbid {
            for nextSeatBid in seatbid {
                guard let bids = nextSeatBid.bid else { continue }
                for nextBid in bids {
                    let bid = Bid(bid: nextBid)
                    allBids.append(bid)
                    
                    if winningBid == nil && bid.price > 0 && bid.isWinning {
                        winningBid = bid
                    } else if let bidTargetingInfo = bid.targetingInfo {
                        targetingInfo.merge(bidTargetingInfo) { $1 }
                    }
                }
            }
        }

        if let winningBidTargetingInfo = winningBid?.targetingInfo {
            targetingInfo.merge(winningBidTargetingInfo) { $1 }
        }

        self.winningBid = winningBid
        self.allBids = allBids
        self.targetingInfo = targetingInfo.count > 0 ? targetingInfo : nil
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
}

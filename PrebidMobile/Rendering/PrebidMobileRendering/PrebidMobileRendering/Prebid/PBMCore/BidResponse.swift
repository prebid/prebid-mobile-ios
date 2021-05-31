//
//  BidResponse.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class BidResponse: NSObject {
    
    @objc public private(set) var allBids: [Bid]?
    @objc public private(set) var winningBid: Bid?
    @objc public private(set) var targetingInfo: [String : String]?
    
    @objc public private(set) var tmaxrequest: NSNumber?
    
    private(set) var rawResponse: RawBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>?

    @objc public convenience init(jsonDictionary: JsonDictionary) {
        let rawResponse = PBMORTBBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>(
            jsonDictionary: jsonDictionary as! [String : Any],
            extParser: { extDic in
                return PBMORTBBidResponseExt(jsonDictionary: extDic)
            },
            seatBidExtParser: { extDic in
                return extDic as NSDictionary
            },
            bidExtParser: { extDic in
                return PBMORTBBidExt(jsonDictionary: extDic)
            })

        self.init(rawBidResponse: rawResponse)
    }
    
    required init(rawBidResponse: RawBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>?) {

        rawResponse = rawBidResponse
        
        guard let rawBidResponse = rawBidResponse else {
            return
        }

        var allBids: [Bid] = []
        var targetingInfo: [String : String] = [:]
        var winningBid: Bid? = nil

        if let seatbid = rawBidResponse.seatbid {
            for nextSeatBid in seatbid {
                for nextBid in nextSeatBid.bid {
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
        tmaxrequest = rawBidResponse.ext.tmaxrequest
    }
 
}

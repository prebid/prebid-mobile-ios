//
//  Bid.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import StoreKit
import UIKit

public class Bid: NSObject {
    /// Bid price expressed as CPM although the actual transaction is for a unit impression only.
    /// Note that while the type indicates float, integer math is highly recommended
    /// when handling currencies (e.g., BigDecimal in Java).
    @objc public var price: Float {
        bid.price.floatValue
    }
    
    /// Win notice URL called by the exchange if the bid wins (not necessarily indicative of a delivered,
    /// viewed, or billable ad); optional means of serving ad markup.
    /// Substitution macros (Section 4.4) may be included in both the URL and optionally returned markup.
    @objc public private(set) var nurl: String?
    
    /// Optional means of conveying ad markup in case the bid wins; supersedes the win notice
    /// if markup is included in both.
    /// Substitution macros (Section 4.4) may be included.
    @objc public private(set) var adm: String?
    
    /// Ad size
    @objc public var size: CGSize {
        guard let w = bid.w, let h = bid.h else {
            return CGSize.zero
        }
        return CGSize(width: CGFloat(w.floatValue), height: CGFloat(h.floatValue))
            
    }
    
    /// Targeting information that needs to be passed to the ad server SDK.
    @objc public var targetingInfo: [String : String]? {
        bid.ext.prebid?.targeting
    }
    
    /// A dictionary with information about SKAdNetwork for loadProcut
    @objc public var skadnInfo: [String : Any]? {
        guard let skadn = bid.ext.skadn else {
            return nil
        }
        if #available(iOS 14.0, *) {
            if let itunesitem = skadn.itunesitem,
               let network = skadn.network,
               let campaign = skadn.campaign,
               let timestamp = skadn.timestamp,
               let nonce = skadn.nonce,
               let signature = skadn.signature,
               let sourceapp = skadn.sourceapp,
               let version = skadn.version {
                return [
                    SKStoreProductParameterITunesItemIdentifier: itunesitem,
                    SKStoreProductParameterAdNetworkIdentifier: network,
                    SKStoreProductParameterAdNetworkCampaignIdentifier: campaign,
                    SKStoreProductParameterAdNetworkTimestamp: timestamp,
                    SKStoreProductParameterAdNetworkNonce: nonce,
                    SKStoreProductParameterAdNetworkAttributionSignature: signature,
                    SKStoreProductParameterAdNetworkSourceAppStoreIdentifier: sourceapp,
                    SKStoreProductParameterAdNetworkVersion: version
                ]
            }
            return nil
        } else {
            return nil
        }
    }
    
    /// Returns YES if this bid is intented for display.
    @objc public var isWinning: Bool {
        guard let targetingInfo = self.targetingInfo else {
            return false
        }

        for markerKey in ["hb_pb", "hb_bidder", "hb_cache_id"] {
            if targetingInfo[markerKey] == nil {
                return false
            }
        }
        return true
    }
    
    @objc public private(set) var bid: PBMORTBBid<PBMORTBBidExt>

    @objc public init(bid: PBMORTBBid<PBMORTBBidExt>) {
        self.bid = bid
        let macrosHelper = PBMORTBMacrosHelper(bid: bid)
        adm = macrosHelper.replaceMacros(in: bid.adm)
        nurl = macrosHelper.replaceMacros(in: bid.nurl)
    }
}

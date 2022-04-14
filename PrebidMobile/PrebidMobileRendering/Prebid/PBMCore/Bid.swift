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
    
    @objc public var skadn: PBMORTBBidExtSkadn? {
        return bid.ext.skadn
    }
    
    /// Prebid ad format
    @objc public var adFormat: AdFormat? {
        AdFormat.allCases.filter { $0.stringEquivalent == bid.ext.prebid?.type }.first
    }
    
    /// Prebid video ad configuration
    @objc public var videoAdConfiguration: PBMORTBAdConfiguration? {
        bid.ext.prebid?.passthrough?.filter { $0.type == "prebidmobilesdk" }.first?.adConfiguration
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

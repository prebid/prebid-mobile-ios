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

@objcMembers
public class Bid: NSObject {
    
    public static let KEY_RENDERER_NAME = "rendererName";
    
    public static let KEY_RENDERER_VERSION = "rendererVersion";
    
    /// Bid price expressed as CPM although the actual transaction is for a unit impression only.
    /// Note that while the type indicates float, integer math is highly recommended
    /// when handling currencies (e.g., BigDecimal in Java).
    @objc public var price: Float {
        bid.price?.floatValue ?? 0.0
    }
    
    /// Billing notice URL called by the exchange when a winning bid
    /// becomes billable based on exchange-specific business policy
    /// (e.g., typically delivered, viewed, etc.). 
    @objc public var burl: String? {
        bid.burl
    }
    
    /// Win notice URL called by the exchange if the bid wins (not necessarily indicative of a delivered,
    /// viewed, or billable ad); optional means of serving ad markup.
    /// Substitution macros (Section 4.4) may be included in both the URL and optionally returned markup.
    public private(set) var nurl: String?
    
    /// Optional means of conveying ad markup in case the bid wins; supersedes the win notice
    /// if markup is included in both.
    /// Substitution macros (Section 4.4) may be included.
    public private(set) var adm: String?
    
    /// Ad size
    public var size: CGSize {
        guard let w = bid.w, let h = bid.h else {
            return CGSize.zero
        }
        return CGSize(width: CGFloat(w.floatValue), height: CGFloat(h.floatValue))
            
    }
    
    /// Targeting information that needs to be passed to the ad server SDK.
    public var targetingInfo: [String : String]? {
        bid.ext?.prebid?.targeting?.compactMapValues { $0 as? String }
    }
    
  /// Targeting information that needs to be passed to the ad server SDK.
    public var meta: [String : Any]? {
        bid.ext?.prebid?.meta
    }
    
    /**
     SKAdNetwork parameters about an App Store product.
     Used in the StoreKit
     */
    public var skadn: PBMORTBBidExtSkadn? {
        return bid.ext?.skadn
    }
    
    /// Prebid ad format
    public var adFormat: AdFormat? {
        AdFormat.allCases.filter { $0.stringEquivalent == bid.ext?.prebid?.type }.first
    }
    
    /// Prebid video ad configuration
    public var videoAdConfiguration: ORTBAdConfiguration? {
        bid.ext?.prebid?.passthrough?.filter { $0.type == "prebidmobilesdk" }.first?.adConfiguration
    }
    
       /// Preffered plugin renderer name
    public var pluginRendererName: String? {
        meta?[Bid.KEY_RENDERER_NAME] as? String
    }
    
    /// Preffered plugin renderer version
    public var pluginRendererVersion: String? {
        meta?[Bid.KEY_RENDERER_VERSION] as? String
    }
    
    // This part is dedicating to test server-side ad configurations.
    // Need to be removed when ext.prebid.passthrough will be available.
    #if DEBUG
    public var testVideoAdConfiguration: ORTBAdConfiguration? {
        bid.ext?.passthrough?.filter { $0.type == "prebidmobilesdk" }.first?.adConfiguration
    }
    #endif
    
    public var rewardedConfig: ORTBRewardedConfiguration? {
        bid.ext?.prebid?.passthrough?.filter { $0.type == "prebidmobilesdk" }.first?.rewardedConfiguration
    }
    
    /// Returns YES if this bid is intented for display.
    public var isWinning: Bool {
        guard let targetingInfo = self.targetingInfo else {
            return false
        }
        
        var winningBidMarkers = ["hb_pb", "hb_bidder"]
        
        if Prebid.shared.useCacheForReportingWithRenderingAPI {
            winningBidMarkers.append("hb_cache_id")
        }

        for markerKey in winningBidMarkers {
            if targetingInfo[markerKey] == nil {
                return false
            }
        }
        return true
    }
    
    public var events: ORTBExtPrebidEvents? {
        bid.ext?.prebid?.events
    }
    
    var bid: ORTBBid<ORTBBidExt>

    init(bid: ORTBBid<ORTBBidExt>) {
        self.bid = bid
        let macrosHelper = ORTBMacrosHelper(bidPrice: bid.price ?? 0.0)
        adm = macrosHelper.replaceMacros(in: bid.adm)
        nurl = macrosHelper.replaceMacros(in: bid.nurl)
    }
}

extension Bid {

    static func bid(from bidString: String) -> Bid? {
        guard let bidDic = Utils.shared.getDictionaryFromString(bidString),
              let rawBid = ORTBBid<ORTBBidExt>(
                jsonDictionary: bidDic,
                extParser: { ORTBBidExt(jsonDictionary: $0)}
              ) else { return nil }

        return Bid(bid: rawBid)
    }
}

// MARK: Impression Tracking Helpers

@objc public extension Bid {
    
     var impressionTrackingURLs: [String] {
        var urls = [String]()
        
        if let burl {
            urls.append(burl)
        }
        
        return urls
    }
}

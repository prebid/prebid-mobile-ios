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
    
    /// Initializes a new `BidInfo` instance with the specified parameters.
    /// - Parameters:
    ///   - resultCode: The result code of the bid request.
    ///   - targetingKeywords: Optional targeting keywords associated with the bid.
    ///   - exp: Optional expiration time of the bid.
    ///   - nativeAdCacheId: Optional cache ID for native ads.
    ///   - events: Optional dictionary of events related to the bid.
    public init(resultCode: ResultCode, targetingKeywords: [String : String]? = nil, exp: Double? = nil,
                nativeAdCacheId: String? = nil, events: [String: String] = [:]) {
        self.resultCode = resultCode
        self.targetingKeywords = targetingKeywords
        self.exp = exp
        self.nativeAdCacheId = nativeAdCacheId
        self.events = events
        
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
            nativeAdCacheId: bidResponse.targetingInfo?[PrebidLocalCacheIdKey]
        )
        
        if let winURL = bidResponse.winningBid?.events?.win {
            bidInfo.addEvent(key: BidInfo.EVENT_WIN, value: winURL)
        }
        
        if let impURL = bidResponse.winningBid?.events?.win {
            bidInfo.addEvent(key: BidInfo.EVENT_IMP, value: impURL)
        }
        
        return bidInfo
    }
    
    func addEvent(key: String, value: String) {
        events[key] = value
    }
}

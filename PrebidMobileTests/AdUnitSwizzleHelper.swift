/*   Copyright 2018-2019 Prebid.org, Inc.

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
@testable import PrebidMobile

@objcMembers
public class AdUnitSwizzleHelper: NSObject {

    private override init() { }
    
    static var testScenario = ResultCode.prebidDemandFetchSuccess
    static var targetingKeywords: [String: String]?
    static var exp: Double?
    static var nativeAdCacheId: String?
   
    class func toggleFetchDemand() {
        
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(adObject:completion:)), cls2: AdUnitSwizzleHelper.self, sel2: #selector(AdUnitSwizzleHelper.swizzledFetchDemand(adObject:completion:)))
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(completion:)), cls2: AdUnitSwizzleHelper.self, sel2: #selector(AdUnitSwizzleHelper.swizzledFetchDemand(completion:)))
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(completionBidInfo:)), cls2: AdUnitSwizzleHelper.self, sel2: #selector(AdUnitSwizzleHelper.swizzledFetchDemand(completionBidInfo:)))
    }
    
    class func toggleCheckRefreshTime() {
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.checkRefreshTime(_:)), cls2: AdUnitSwizzleHelper.self, sel2: #selector(AdUnitSwizzleHelper.swizzledCheckRefreshTime(_:)))
    }

    func swizzledFetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        completion(AdUnitSwizzleHelper.testScenario)
    }
    
    func swizzledFetchDemand(completion: @escaping(_ result: ResultCode, _ kvResultDict: [String : String]?) -> Void) {
        completion(AdUnitSwizzleHelper.testScenario, AdUnitSwizzleHelper.targetingKeywords)
    }
    
    func swizzledFetchDemand(completionBidInfo: @escaping (_ bidInfo: BidInfo) -> Void) {
        completionBidInfo(BidInfo(
            resultCode: AdUnitSwizzleHelper.testScenario,
            targetingKeywords: AdUnitSwizzleHelper.targetingKeywords,
            exp: AdUnitSwizzleHelper.exp,
            nativeAdCacheId: AdUnitSwizzleHelper.nativeAdCacheId)
        )
    }
    
    func swizzledCheckRefreshTime(_ time: Double) -> Bool {
        return true
    }
}

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

@objcMembers
@objc(PBMBidInfo)
public class BidInfo: NSObject {
  
    public private(set) var resultCode: ResultCode
    public private(set) var targetingKeywords: [String: String]?
    public private(set) var exp: Double?
    public private(set) var nativeAdCacheId: String?
    
    public init(resultCode: ResultCode, targetingKeywords: [String : String]? = nil, exp: Double? = nil, nativeAdCacheId: String? = nil) {
        self.resultCode = resultCode
        self.targetingKeywords = targetingKeywords
        self.exp = exp
        self.nativeAdCacheId = nativeAdCacheId
        
        super.init()
    }
}

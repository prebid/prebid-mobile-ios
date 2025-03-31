//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objcMembers
public class PBMORTBBidExtPrebidCacheBids: PBMORTBAbstract {
    public var url: String?
    public var cacheId: String?
    
    override init() {
        super.init()
    }
    
    override public init(jsonDictionary: [String : Any]) {
        url = jsonDictionary[key: "url"]
        cacheId = jsonDictionary[key: "cacheId"]
        
        super.init()
    }
    
    override public func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["url"] = url
        ret["cacheId"] = cacheId
        
        return ret
    }
}

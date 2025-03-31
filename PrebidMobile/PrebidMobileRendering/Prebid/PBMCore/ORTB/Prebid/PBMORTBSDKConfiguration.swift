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
public class PBMORTBSDKConfiguration: PBMORTBAbstract {
    public var cftBanner: NSNumber?
    public var cftPreRender: NSNumber?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        cftBanner = jsonDictionary[key: "cftbanner"]
        cftPreRender = jsonDictionary[key: "cftprerender"]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["cftbanner"] = cftBanner
        ret["cftprerender"] = cftPreRender
        
        return ret
    }
}

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
public class PBMORTBAdConfiguration: PBMORTBAbstract {
    public var maxVideoDuration: NSNumber?
    public var isMuted: NSNumber?
    public var closeButtonArea: NSNumber?
    public var closeButtonPosition: String?
    public var skipButtonArea: NSNumber?
    public var skipButtonPosition: String?
    public var skipDelay: NSNumber?
    
    override init() {
        super.init()
    }
    
    override public init(jsonDictionary: [String : Any]) {
        maxVideoDuration = jsonDictionary[key: "maxvideoduration"]
        isMuted = jsonDictionary[key: "ismuted"]
        closeButtonArea = jsonDictionary[key: "closebuttonarea"]
        closeButtonPosition = jsonDictionary[key: "closebuttonposition"]
        skipButtonArea = jsonDictionary[key: "skipbuttonarea"]
        skipButtonPosition = jsonDictionary[key: "skipbuttonposition"]
        skipDelay = jsonDictionary[key: "skipdelay"]
        
        super.init()
    }
    
    override public func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["maxvideoduration"] = maxVideoDuration
        ret["ismuted"] = isMuted
        ret["closebuttonarea"] = closeButtonArea
        ret["closebuttonposition"] = closeButtonPosition
        ret["skipbuttonarea"] = skipButtonArea
        ret["skipbuttonposition"] = skipButtonPosition
        ret["skipdelay"] = skipDelay
        
        return ret
    }
}

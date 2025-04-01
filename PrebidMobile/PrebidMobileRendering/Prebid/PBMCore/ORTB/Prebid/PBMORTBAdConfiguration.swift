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
    
    private enum KeySet: String {
        case maxvideoduration
        case ismuted
        case closebuttonarea
        case closebuttonposition
        case skipbuttonarea
        case skipbuttonposition
        case skipdelay
    }
    
    override init() {
        super.init()
    }
    
    override public init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        maxVideoDuration = json[.maxvideoduration]
        isMuted = json[.ismuted]
        closeButtonArea = json[.closebuttonarea]
        closeButtonPosition = json[.closebuttonposition]
        skipButtonArea = json[.skipbuttonarea]
        skipButtonPosition = json[.skipbuttonposition]
        skipDelay = json[.skipdelay]
        
        super.init()
    }
    
    override public func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.maxvideoduration] = maxVideoDuration
        json[.ismuted] = isMuted
        json[.closebuttonarea] = closeButtonArea
        json[.closebuttonposition] = closeButtonPosition
        json[.skipbuttonarea] = skipButtonArea
        json[.skipbuttonposition] = skipButtonPosition
        json[.skipdelay] = skipDelay
        
        return json.dict
    }
}

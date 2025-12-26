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

@objc open class ORTBAdConfiguration: NSObject, PBMJsonCodable {
    @objc public var maxVideoDuration: NSNumber?
    @objc public var isMuted: NSNumber?
    @objc public var closeButtonArea: NSNumber?
    @objc public var closeButtonPosition: String?
    @objc public var skipButtonArea: NSNumber?
    @objc public var skipButtonPosition: String?
    @objc public var skipDelay: NSNumber?

    private enum KeySet: String {
        case maxvideoduration
        case ismuted
        case closebuttonarea
        case closebuttonposition
        case skipbuttonarea
        case skipbuttonposition
        case skipdelay
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        maxVideoDuration    = json[.maxvideoduration]
        isMuted             = json[.ismuted]
        closeButtonArea     = json[.closebuttonarea]
        closeButtonPosition = json[.closebuttonposition]
        skipButtonArea      = json[.skipbuttonarea]
        skipButtonPosition  = json[.skipbuttonposition]
        skipDelay           = json[.skipdelay]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.maxvideoduration]     = maxVideoDuration
        json[.ismuted]              = isMuted
        json[.closebuttonarea]      = closeButtonArea
        json[.closebuttonposition]  = closeButtonPosition
        json[.skipbuttonarea]       = skipButtonArea
        json[.skipbuttonposition]   = skipButtonPosition
        json[.skipdelay]            = skipDelay

        return json.dict
    }
}

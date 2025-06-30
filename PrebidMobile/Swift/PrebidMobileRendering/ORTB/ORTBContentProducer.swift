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

@objc(PBMORTBContentProducer)
public class ORTBContentProducer: NSObject, PBMJsonCodable {
    
    /// Content producer or originator ID.
    @objc public var id: String?
    
    /// Content producer or originator name
    @objc public var name: String?
    
    /// Array of IAB content categories that describe the content producer.
    @objc public var cat: [String]?
    
    /// Highest level domain of the content producer.
    @objc public var domain: String?
    
    /// Placeholder for exchange-specific extensions to OpenRTB.
    @objc public var ext: [String : Any]?

    private enum KeySet: String {
        case id
        case name
        case cat
        case domain
        case ext
    }
    
    public override init() {
        super.init()
    }
        
    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        id          = json[.id]
        name        = json[.name]
        cat         = json[.cat]
        domain      = json[.domain]
        ext         = json[.ext]
    }
    
    @objc(toJsonDictionary)
    public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.id]           = id
        json[.name]         = name
        json[.cat]          = cat
        json[.domain]       = domain
        json[.ext]          = ext
        
        return json.dict
    }
}

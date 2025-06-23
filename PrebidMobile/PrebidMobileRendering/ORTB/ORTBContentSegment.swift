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

@objc(PBMORTBContentSegment)
public class ORTBContentSegment: NSObject, PBMJsonCodable {
    
    /// ID of the data segment specific to the data provider.
    @objc public var id: String?
    
    /// Name of the data segment specific to the data provider.
    @objc public var name: String?
    
    /// String representation of the data segment value.
    @objc public var value: String?
    
    /// Placeholder for exchange-specific extensions to OpenRTB.
    @objc public var ext: [String : Any]?

    private enum KeySet: String {
        case id
        case name
        case value
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
        value       = json[.value]
        ext         = json[.ext]
    }
    
    @objc(toJsonDictionary)
    public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.id]       = id
        json[.name]     = name
        json[.value]    = value
        json[.ext]      = ext
        
        return json.dict
    }
}

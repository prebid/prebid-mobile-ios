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

@objc(PBMORTBNative)
public class ORTBNative: NSObject, PBMJsonCodable {
    
    /// [Required]
    /// Request payload complying with the Native Ad Specification.
    @objc public var request: String?
    
    /// [Recommended]
    /// Version of the Dynamic Native Ads API to which `request` complies; highly recommended for efficient parsing.
    @objc public var ver: String?
    
    /// [Integer Array]
    /// List of supported API frameworks for this impression. Refer to List 5.6. If an API is not explicitly listed, it is assumed not to be supported.
    @objc public var api: [NSNumber]?
    
    /// [Integer Array]
    /// Blocked creative attributes. Refer to List 5.3.
    @objc public var battr: [NSNumber]?

    private enum KeySet: String {
        case request
        case ver
        case api
        case battr
    }
    
    public override init() {
        super.init()
        ver = "1.2"
    }
    
    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        request  = json[.request]
        ver      = json[.ver]
        api      = json[.api]
        battr    = json[.battr]
    }
    
    @objc(toJsonDictionary)
    public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.request]  = request
        json[.ver]      = ver
        json[.api]      = api
        json[.battr]    = battr
        
        return json.dict
    }
}

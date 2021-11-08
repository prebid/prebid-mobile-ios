/*   Copyright 2018-2021 Prebid.org, Inc.

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

class PBRNativeAsset: NSObject, NSCopying, PBMJsonCodable {
    
    /// [Required]
    /// [Integer]
    /// Unique asset ID, assigned by exchange. Typically a counter for the array.
    /// Assigned by SDK.
    @objc public var assetID: NSNumber?
    
    /// [Integer]
    /// Set to 1 if asset is required (exchange will not accept a bid without it)
    @objc public var required: NSNumber?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties
    /// to support flexibility beyond the standard defined in this specification
    @objc private(set) public var assetExt: [String : Any]?
    
    @objc private(set) public var childExt: [String : Any]?
    
    var childType: String
    
    private override init() {
        PBMLog.warn("NativeAsset class should not be instantialted directly, instantiate subclasses instead.")
        self.childType = ""
    }
    
    init(childType: String) {
        self.childType = childType
        super.init()
    }

    @objc public func setAssetExt(_ assetExt: [String : Any]?) throws {
        let nsExt = assetExt as NSDictionary?
        let newExt = try nsExt?.unserializedCopy()
        self.assetExt = newExt
    }
    
    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let result = PBRNativeAsset(childType: childType)
        copyOptionalProperties(into: result)
        return result
    }

    func copyOptionalProperties(into clone: PBRNativeAsset) {
        clone.assetID = assetID
        clone.required = required
        clone.assetExt = assetExt
        clone.childExt = childExt
    }
    
    // MARK: - PBMJsonCodable
    
    @objc public var jsonDictionary: [String : Any]? {
        let assetProperties = MutableJsonDictionary()
        appendAssetProperties(to: assetProperties)
        let childProperties = MutableJsonDictionary()
        appendChildProperties(to: childProperties)
        assetProperties[self.childType] = childProperties.count != 0 ? childProperties : nil;
        
        return assetProperties as? [String : Any]
    }
    
    @objc public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary!)
    }
    
    // MARK: - Protected
    
    @objc public func setChildExt(_ childExt: [String : Any]?) throws {
        let nsExt = childExt as NSDictionary?
        let newExt = try nsExt?.unserializedCopy()
        self.childExt = newExt
    }
    
    func appendAssetProperties(to jsonDictionary: MutableJsonDictionary) {
        jsonDictionary["id"] = assetID
        jsonDictionary["required"] = required as? Int
        jsonDictionary["ext"] = assetExt
    }

    func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        jsonDictionary["ext"] = childExt
    }
}

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

public class PBRNativeAssetData : PBRNativeAsset {
    /// [Required]
    /// [Integer]
    /// Type ID of the element supported by the publisher.
    /// The publisher can display this information in an appropriate format.
    /// See Data Asset Types table for commonly used examples.
    @objc public var dataType: NativeDataAssetType
    
    /// [Integer]
    /// Maximum length of the text in the element’s response.
    @objc public var length: NSNumber?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties
    /// to support flexibility beyond the standard defined in this specification
    @objc public var dataExt: [String : Any]? { childExt }
    
    // MARK: - Lifecycle
    
    @objc public required init(dataType: NativeDataAssetType) {
        self.dataType = dataType
        super.init(childType: "data")
    }
    
    // MARK: - NSCopying

    @objc public override func copy(with zone: NSZone? = nil) -> Any {
        let result = PBRNativeAssetData(dataType: dataType)
        copyOptionalProperties(into: result)
        return result
    }

    public override func copyOptionalProperties(into clone: PBRNativeAsset) {
        super.copyOptionalProperties(into: clone)
        if let dataClone = clone as? PBRNativeAssetData {
            dataClone.length = length
        }
    }
    
    @objc public func setDataExt(_ dataExt: [String : Any]) throws {
        try setChildExt(dataExt)
    }

    // MARK: - Protected

    public override func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        super.appendChildProperties(to: jsonDictionary)
        jsonDictionary["type"] = NSNumber(value: dataType.rawValue)
        jsonDictionary["len"] = length
    }
}

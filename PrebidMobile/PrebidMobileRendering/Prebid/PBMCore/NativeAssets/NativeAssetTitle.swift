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

class PBRNativeAssetTitle: PBRNativeAsset {
    /// [Required]
    /// [Integer]
    /// Maximum length of the text in the title element.
    /// Recommended to be 25, 90, or 140.
    @objc public var length = 0
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties
    /// to support flexibility beyond the standard defined in this specification
    @objc public var titleExt: [String : Any]? { childExt }
    
    
    // MARK: - Lifecycle
    
    @objc public required init(length: Int) {
        self.length = length
        super.init(childType: "title")
    }

    // MARK: - NSCopying

    @objc public override func copy(with zone: NSZone? = nil) -> Any {
        let result = PBRNativeAssetTitle(length: length)
        copyOptionalProperties(into: result)
        return result
    }

    
    @objc public func setTitleExt(_ titleExt: [String : Any] ) throws {
        try setChildExt(titleExt)
    }


    // MARK: - Protected

    public override func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        super.appendChildProperties(to: jsonDictionary)
        jsonDictionary["len"] = NSNumber(value: length)
    }
}

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

public class PBRNativeAssetImage: PBRNativeAsset {
    
    /// [Integer]
    /// Type ID of the image element supported by the publisher. The publisher can display
    /// this information in an appropriate format.
    @objc public var imageType: NSNumber?
    
    /// [Integer]
    /// Width of the image in pixels.
    @objc public var width: NSNumber?
    
    /// [Recommended]
    /// [Integer]
    /// The minimum requested width of the image in pixels.
    /// This option should be used for any rescaling of images by the client.
    /// Either w or wmin should be transmitted.
    /// If only w is included, it should be considered an exact requirement.
    @objc public var widthMin: NSNumber?
    
    /// [Integer]
    /// Height of the image in pixels.
    @objc public var height: NSNumber?
    
    /// [Recommended]
    /// [Integer]
    /// The minimum requested height of the image in pixels.
    /// This option should be used for any rescaling of images by the client.
    /// Either h or hmin should be transmitted.
    /// If only h is included, it should be considered an exact requirement.
    @objc public var heightMin: NSNumber?
    
    /// Whitelist of content MIME types supported.
    /// Popular MIME types include, but are not limited to “image/jpg” “image/gif”.
    /// Each implementing Exchange should have their own list of supported types in the integration docs.
    /// See Wikipedia's MIME page for more information and links to all IETF RFCs.
    /// If blank, assume all types are allowed.
    @objc public var mimeTypes: [String]?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var imageExt: [String : Any]? { childExt }

    // MARK: - Lifecycle
    
    @objc public required init(imageType: NSNumber? = nil) {
        self.imageType = imageType
        super.init(childType: "img")
    }
    
    // MARK: - NSCopying

    @objc public override func copy(with zone: NSZone? = nil) -> Any {
        let result = PBRNativeAssetImage()
        copyOptionalProperties(into: result)
        return result
    }

    public override func copyOptionalProperties(into clone: PBRNativeAsset) {
        super.copyOptionalProperties(into: clone)
        if let imageClone = clone as? PBRNativeAssetImage {
            imageClone.imageType = imageType
            imageClone.width = width
            imageClone.height = height
            imageClone.widthMin = widthMin
            imageClone.heightMin = heightMin
            imageClone.mimeTypes = mimeTypes
        }
    }
    
    // MARK: - Image Ext
    
    @objc public func setImageExt(_ imageExt: [String : Any]) throws {
        try setChildExt(imageExt)
    }
    
    // MARK: - Protected

    public override func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        super.appendChildProperties(to: jsonDictionary)
        jsonDictionary["type"] = imageType
        jsonDictionary["w"] = width
        jsonDictionary["h"] = height
        jsonDictionary["wmin"] = widthMin
        jsonDictionary["hmin"] = heightMin
        jsonDictionary["mimes"] = mimeTypes
    }
}


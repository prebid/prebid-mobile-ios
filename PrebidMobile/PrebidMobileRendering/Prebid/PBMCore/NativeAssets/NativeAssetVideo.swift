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

class NativeAssetVideo: PBRNativeAsset {
    
    /// [Required]
    /// Content MIME types supported.
    /// Popular MIME types include, but are not limited to
    /// “video/x-ms- wmv” for Windows Media, and
    /// “video/x-flv” for Flash Video, or “video/mp4”.
    /// Note that native frequently does not support flash.
    @objc public var mimeTypes: [String]
    
    /// [Required]
    /// Minimum video ad duration in seconds.
    @objc public var minDuration = 0
    
    /// [Required]
    /// Maximum video ad duration in seconds.
    @objc public var maxDuration = 0
    
    /// [Required]
    /// An array of video protocols the integers publisher can accept in the bid response.
    /// See OpenRTB Table ‘Video Bid Response Protocols’ for a list of possible values.
    @objc public var protocols: [NSNumber]

    /// This object is a placeholder that may contain custom JSON agreed to by the parties
    /// to support flexibility beyond the standard defined in this specification
    @objc public var videoExt: [String : Any]? { childExt }

    // MARK: - Lifecycle
    
    @objc public required init(mimeTypes: [String],
                               minDuration: Int,
                               maxDuration: Int,
                               protocols: [NSNumber]) {
        self.mimeTypes = mimeTypes
        self.minDuration = minDuration
        self.maxDuration = maxDuration
        self.protocols = protocols
        
        super.init(childType: "video")
    }

    // MARK: - NSCopying

    @objc public override func copy(with zone: NSZone? = nil) -> Any {
        let result = NativeAssetVideo(mimeTypes: mimeTypes,
                                          minDuration: minDuration,
                                          maxDuration: maxDuration,
                                          protocols: protocols)
        copyOptionalProperties(into: result)
        return result
    }

    @objc public func setVideoExt(_ videoExt: [String : Any]) throws {
        try setChildExt(videoExt)
    }

    // MARK: - Protected

    public override func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        super.appendChildProperties(to: jsonDictionary)
        jsonDictionary["mimes"] = mimeTypes
        jsonDictionary["minDuration"] = NSNumber(value: minDuration)
        jsonDictionary["maxDuration"] = NSNumber(value: maxDuration)
        jsonDictionary["protocols"] = protocols
    }
}

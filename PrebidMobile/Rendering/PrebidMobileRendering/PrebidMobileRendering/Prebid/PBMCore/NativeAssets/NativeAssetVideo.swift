//
//  NativeAssetVideo.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAssetVideo: NativeAsset {
    
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

    @objc public func setVideoExt(_ videoExt: [String : Any]?) throws {
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

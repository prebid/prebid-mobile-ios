//
//  NativeAssetTitle.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAssetTitle: NativeAsset {
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
        let result = NativeAssetTitle(length: length)
        copyOptionalProperties(into: result)
        return result
    }

    
    @objc public func setTitleExt(_ titleExt: [String : Any]? ) throws {
        try setChildExt(titleExt)
    }


    // MARK: - Protected

    public override func appendChildProperties(to jsonDictionary: MutableJsonDictionary) {
        super.appendChildProperties(to: jsonDictionary)
        jsonDictionary["len"] = NSNumber(value: length)
    }
}

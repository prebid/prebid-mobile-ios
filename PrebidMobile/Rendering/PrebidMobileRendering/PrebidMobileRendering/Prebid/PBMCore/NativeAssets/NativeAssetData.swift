//
//  NativeAssetData.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAssetData : NativeAsset {
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
        let result = NativeAssetData(dataType: dataType)
        copyOptionalProperties(into: result)
        return result
    }

    public override func copyOptionalProperties(into clone: NativeAsset) {
        super.copyOptionalProperties(into: clone)
        if let dataClone = clone as? NativeAssetData {
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

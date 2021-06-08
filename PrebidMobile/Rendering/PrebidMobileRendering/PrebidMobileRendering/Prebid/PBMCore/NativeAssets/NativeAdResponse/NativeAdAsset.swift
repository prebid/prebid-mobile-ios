//
//  NativeAdAsset.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdAsset: NSObject {

    /// [Integer]
    /// Optional if assetsurl/dcourl is being used
    /// Required if embedded asset is being used.
    @objc public var assetID: NSNumber? {
        nativeAdMarkupAsset.assetID
    }
    
    /// [Integer]
    /// Set to 1 if asset is required (bidder requires it to be displayed)
    @objc public var required: NSNumber? {
        nativeAdMarkupAsset.required
    }

    /// Link object for call to actions.
    /// The link object applies if the asset item is activated (clicked).
    /// If there is no link object on the asset, the parent link object on the bid response applies.
    @objc public var link: PBMNativeAdMarkupLink? {
        nativeAdMarkupAsset.link
    }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var assetExt: [String : AnyHashable]? {
        nativeAdMarkupAsset.ext as? [String : AnyHashable]
    }
    
    private(set) var nativeAdMarkupAsset: PBMNativeAdMarkupAsset

    @objc public required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        self.nativeAdMarkupAsset = nativeAdMarkupAsset
    }

    // MARK: - NSCopying
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        if !(object is Self) {
            return false
        }
        let other = object as? Self
        return self === other || nativeAdMarkupAsset == other?.nativeAdMarkupAsset
    }
    
    // MARK: - Private
    @available(*, unavailable)
    override init() {
        fatalError("Init is unavailable. Use init(nativeAdMarkupAsset:) instead")
    }
}

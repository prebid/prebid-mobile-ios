//
//  NativeAdTitle.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdTitle: NativeAdAsset {

    /// The text associated with the text element.
    @objc public var text: String { nativeAdMarkupAsset.title?.text ?? "" }

    /// [Integer]
    /// The length of the title being provided.
    /// Required if using assetsurl/dcourl representation, optional if using embedded asset representation.
    @objc public var length: NSNumber? { nativeAdMarkupAsset.title?.length }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var titleExt: [String : Any]? { nativeAdMarkupAsset.title?.ext }

    @objc public required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        guard let _ = nativeAdMarkupAsset.title else {
            throw NativeAdAssetBoxingError.noTitleInsideNativeAdMarkupAsset
        }
        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
}

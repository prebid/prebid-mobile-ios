//
//  NativeAdImage.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdImage: NativeAdAsset {

    /// [Integer]
    /// The type of image element being submitted from the Image Asset Types table.
    /// Required for assetsurl or dcourl responses, not required for embedded asset responses.
    @objc public var imageType: NSNumber? { nativeAdMarkupAsset.img?.imageType }

    /// URL of the image asset.
    @objc public var url: String { nativeAdMarkupAsset.img?.url ?? "" }

    /// [Integer]
    /// Width of the image in pixels.
    /// Recommended for embedded asset responses.
    /// Required for assetsurl/dcourlresponses if multiple assets of same type submitted.
    @objc public var width: NSNumber? { nativeAdMarkupAsset.img?.width }

    /// [Integer]
    /// Height of the image in pixels.
    /// Recommended for embedded asset responses.
    /// Required for assetsurl/dcourl responses if multiple assets of same type submitted.
    @objc public var height: NSNumber? { nativeAdMarkupAsset.img?.height }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var imageExt: [String : Any]? { nativeAdMarkupAsset.img?.ext }

    @objc public required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        guard let _ = nativeAdMarkupAsset.img else {
            throw NativeAdAssetBoxingError.noImageInsideNativeAdMarkupAsset
        }

        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
}

//
//  NativeAdData.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdData: NativeAdAsset {

    /// The type of data element being submitted from the Data Asset Types table.
    /// Required for assetsurl/dcourl responses, not required for embedded asset responses.
    @objc public var dataType: NSNumber? { nativeAdMarkupAsset.data?.dataType }

    /// [Integer]
    /// The length of the data element being submitted.
    /// Required for assetsurl/dcourl responses, not required for embedded asset responses.
    /// Where applicable, must comply with the recommended maximum lengths in the Data Asset Types table.
    @objc public var length: NSNumber? { nativeAdMarkupAsset.data?.length }

    /// The formatted string of data to be displayed.
    /// Can contain a formatted value such as “5 stars” or “$10” or “3.4 stars out of 5”.
    @objc public var value: String { nativeAdMarkupAsset.data?.value ?? "" }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var dataExt: [String : Any]? { nativeAdMarkupAsset.data?.ext }

    @objc public required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        guard  let _ = nativeAdMarkupAsset.data else {
            throw NativeAdAssetBoxingError.noDataInsideNativeAdMarkupAsset
        }

        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
}

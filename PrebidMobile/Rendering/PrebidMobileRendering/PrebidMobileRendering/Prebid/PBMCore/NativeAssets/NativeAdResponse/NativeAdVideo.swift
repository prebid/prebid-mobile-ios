//
//  NativeAdVideo.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdVideo: NativeAdAsset {
    
    /// Media data describing this asset
    @objc private(set) public var mediaData: MediaData!

    @objc public init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset, nativeAdHooks: PBMNativeAdMediaHooks) throws {
        guard let _ = nativeAdMarkupAsset.video else {
            throw NativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset
        }
        
        mediaData = MediaData(mediaAsset: nativeAdMarkupAsset, nativeAdHooks: nativeAdHooks)
        
        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
    
    internal required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
}

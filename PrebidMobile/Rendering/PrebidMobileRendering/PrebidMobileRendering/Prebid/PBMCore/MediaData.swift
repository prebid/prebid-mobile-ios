//
//  PBMMediaDataTTT.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MediaData: NSObject {
    
    @objc public let mediaAsset: PBMNativeAdMarkupAsset
    @objc public let nativeAdHooks: PBMNativeAdMediaHooks
    
    @objc public init(mediaAsset: PBMNativeAdMarkupAsset, nativeAdHooks: PBMNativeAdMediaHooks) {
        self.mediaAsset = mediaAsset
        self.nativeAdHooks = nativeAdHooks
    }
}

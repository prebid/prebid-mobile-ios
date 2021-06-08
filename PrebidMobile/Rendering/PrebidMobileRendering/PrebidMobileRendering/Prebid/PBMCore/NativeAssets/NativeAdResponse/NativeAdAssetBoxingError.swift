//
//  NativeAdAssetBoxingError.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

enum NativeAdAssetBoxingError {
    static var noDataInsideNativeAdMarkupAsset: Error {
        NSError(domain: PrebidRenderingErrorDomain,
                code: pbmErrorCode(.incompatibleNativeAdMarkupAsset, 1),
                userInfo: [NSLocalizedDescriptionKey: "NativeAdMarkupAsset has no 'data'"])
    }

    static var noImageInsideNativeAdMarkupAsset: Error {
        NSError(domain: PrebidRenderingErrorDomain,
                code: pbmErrorCode(.incompatibleNativeAdMarkupAsset, 2),
                userInfo: [NSLocalizedDescriptionKey: "NativeAdMarkupAsset has no 'img'"])
    }

    static var noTitleInsideNativeAdMarkupAsset: Error {
        NSError(domain: PrebidRenderingErrorDomain,
                code: pbmErrorCode(.incompatibleNativeAdMarkupAsset, 3),
                userInfo: [NSLocalizedDescriptionKey: "NativeAdMarkupAsset has no 'title'"])
    }

    static var noVideoInsideNativeAdMarkupAsset: Error {
        NSError(domain: PrebidRenderingErrorDomain,
                code: pbmErrorCode(.incompatibleNativeAdMarkupAsset, 4),
                userInfo: [NSLocalizedDescriptionKey: "NativeAdMarkupAsset has no 'video'"])
    }
}

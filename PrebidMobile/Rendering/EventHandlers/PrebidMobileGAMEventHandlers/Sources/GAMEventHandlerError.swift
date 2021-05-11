//
//  GAMEventHandlerError.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

enum GAMEventHandlerError : Error {
    
    case gamClassesNotFound
    case noLocalCacheID
    case invalidLocalCacheID
    case invalidNativeAd
}

fileprivate let errDescrClassNotFound   = "GoogleMobileAds SDK does not provide the required classes."
fileprivate let errDescrNoCacheID       = "Failed to find local cache ID (expected in \(Constants.targetingKeyLocalCacheID)."
fileprivate let errDescrInvalidCacheID  = "Invalid local cache ID or the Ad already expired."
fileprivate let errDescrInvalidNativeAd = "Failed to load Native Ad from cached bid response."

extension GAMEventHandlerError : LocalizedError {
    public var errorDescription: String? {
        switch self {
    
            case .gamClassesNotFound    : return errDescrClassNotFound
            case .noLocalCacheID        : return errDescrNoCacheID
            case .invalidLocalCacheID   : return errDescrInvalidCacheID
            case .invalidNativeAd       : return errDescrInvalidNativeAd
        }
    }
}

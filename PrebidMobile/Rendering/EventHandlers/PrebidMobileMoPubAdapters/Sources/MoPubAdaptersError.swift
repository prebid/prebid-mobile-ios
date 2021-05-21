//
//  GAMEventHandlerError.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

enum MoPubAdaptersError : Error {
    
    case emptyLocalExtras
    case noBidInLocalExtras
    case noConfigIDInLocalExtras
    case noAd
    
    case noLocalCacheID
    case invalidLocalCacheID
    case invalidNativeAd
    
    case unknown
}

enum MoPubAdaptersErrorCodes : Int {

    case generalLinear  = 400
    case fileNotFound   = 401
    case nonLinearAds   = 500
    case general        = 700
    case undefined      = 900
    
}

fileprivate let MoPubAdaptersErrorDomain = "org.prebid.mobile.rendering.ErrorDomain";


fileprivate let errDescrEmptyLocalExtras        = "The local extras is empty"
fileprivate let errDescrNoBidInLocalExtras      = "The Bid object is absent in the extras"
fileprivate let errDescrNoConfigIDInLocalExtras = "The Config ID absent in the extras"
fileprivate let errDescrNoAd                    = "The ad hasn’t been loaded"
fileprivate let errDescrUnknown                 = "Unknown error has been received."
fileprivate let errDescrNoCacheID               = "Failed to find local cache ID (expected in ????."
fileprivate let errDescrInvalidCacheID          = "Invalid local cache ID or the Ad already expired."
fileprivate let errDescrInvalidNativeAd         = "Failed to load Native Ad from cached bid response."

extension MoPubAdaptersError : LocalizedError {
    public var errorDescription: String? {
        switch self {
    
            case .emptyLocalExtras          : return errDescrEmptyLocalExtras
            case .noBidInLocalExtras        : return errDescrNoBidInLocalExtras
            case .noConfigIDInLocalExtras   : return errDescrNoConfigIDInLocalExtras
            case .noAd                      : return errDescrNoAd
                
            case .noLocalCacheID            : return errDescrNoCacheID
            case .invalidLocalCacheID       : return errDescrInvalidCacheID
            case .invalidNativeAd           : return errDescrInvalidNativeAd
                
            case .unknown                   : return errDescrUnknown
        }
    }
}

extension MoPubAdaptersError :  CustomNSError {
    static var errorDomain: String {
        MoPubAdaptersErrorDomain
    }
    
    public var errorCode: Int {
        switch self {
            case .emptyLocalExtras          : return MoPubAdaptersErrorCodes.general.rawValue
            case .noBidInLocalExtras        : return MoPubAdaptersErrorCodes.general.rawValue
            case .noConfigIDInLocalExtras   : return MoPubAdaptersErrorCodes.general.rawValue
            case .noAd                      : return MoPubAdaptersErrorCodes.general.rawValue

            case .noLocalCacheID            : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .invalidLocalCacheID       : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .invalidNativeAd           : return MoPubAdaptersErrorCodes.undefined.rawValue
                
            case .unknown                   : return MoPubAdaptersErrorCodes.undefined.rawValue
        }
    }
}

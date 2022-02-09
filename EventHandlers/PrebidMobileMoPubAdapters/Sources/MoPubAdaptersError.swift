/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public enum MoPubAdaptersError : Error {
    
    case emptyLocalExtras
    case noBidInLocalExtras
    case noConfigIDInLocalExtras
    case noAd
    
    case noLocalCacheID
    case invalidLocalCacheID
    case invalidNativeAd
    case nonPrebidAd
    case unknown
}

public enum MoPubAdaptersErrorCodes : Int {

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
fileprivate let errDescrNonPrebidAd             = "The ad is not Prebid ad"

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
            case .nonPrebidAd               : return errDescrNonPrebidAd
            case .unknown                   : return errDescrUnknown
        }
    }
}

extension MoPubAdaptersError :  CustomNSError {
    public static var errorDomain: String {
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
            case .nonPrebidAd               : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .unknown                   : return MoPubAdaptersErrorCodes.undefined.rawValue
        }
    }
}

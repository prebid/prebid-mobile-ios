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
import PrebidMobile

@objc public enum GAMEventHandlerError: Int, Error {
    
    case gamClassesNotFound = 0
    case noLocalCacheID
    case invalidLocalCacheID
    case invalidNativeAd
    case nonPrebidAd
    case noAd
}

fileprivate let errDescrClassNotFound   = "GoogleMobileAds SDK does not provide the required classes."
fileprivate let errDescrNoCacheID       = "Failed to find local cache ID (expected in \(PrebidLocalCacheIdKey)."
fileprivate let errDescrInvalidCacheID  = "Invalid local cache ID or the Ad already expired."
fileprivate let errDescrInvalidNativeAd = "Failed to load Native Ad from cached bid response."
fileprivate let errDescrNonPrebidAd     = "The ad is not Prebid ad"
fileprivate let errDescrNoAd            = "The ad hasn’t been loaded"

extension GAMEventHandlerError : LocalizedError {
    public var errorDescription: String? {
        switch self {
    
            case .gamClassesNotFound    : return errDescrClassNotFound
            case .noLocalCacheID        : return errDescrNoCacheID
            case .invalidLocalCacheID   : return errDescrInvalidCacheID
            case .invalidNativeAd       : return errDescrInvalidNativeAd
            case .nonPrebidAd           : return errDescrNonPrebidAd
            case .noAd                  : return errDescrNoAd
        }
    }
}

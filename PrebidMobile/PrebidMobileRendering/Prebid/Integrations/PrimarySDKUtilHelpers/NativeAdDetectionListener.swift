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

typealias NativeAdLoadedHandler = (PBRNativeAd) -> Void
typealias PrimaryAdServerWinHandler = () -> Void
typealias InvalidNativeAdHandler = (Error) -> Void

/// Immutable container for 3 mutually exclusive outcomes of an asynchronous native ad detection attempt.
class NativeAdDetectionListener: NSObject, NSCopying {
    
    @objc public private(set) var onNativeAdLoaded: NativeAdLoadedHandler?
    @objc public private(set) var onPrimaryAdWin: PrimaryAdServerWinHandler?
    @objc public private(set) var onNativeAdInvalid: InvalidNativeAdHandler?

    @objc public required init(nativeAdLoadedHandler onNativeAdLoaded: NativeAdLoadedHandler?,
                               onPrimaryAdWin: PrimaryAdServerWinHandler?,
                               onNativeAdInvalid: InvalidNativeAdHandler?) {
        self.onNativeAdLoaded = onNativeAdLoaded
        self.onPrimaryAdWin = onPrimaryAdWin
        self.onNativeAdInvalid = onNativeAdInvalid
    }

    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    // MARK: - Private
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }

}

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

/// A protocol that defines methods for receiving loading events related to interstitial ad controllers.
@objc
public protocol InterstitialControllerLoadingDelegate: NSObjectProtocol {

    /// Notifies the delegate that the interstitial ad has successfully loaded.
    ///
    /// - Parameters:
    ///    - interstitialController: The interstitial ad controller that successfully loaded the ad.
    @objc func interstitialControllerDidLoadAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )
    
    /// Notifies the delegate that an error occurred during the interstitial ad loading process.
    ///
    /// - Parameters:
    ///   - interstitialController: The interstitial ad controller that attempted to load the ad.
    ///   - error: An `Error` instance describing the issue that occurred during the ad loading.
    @objc func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    )
}

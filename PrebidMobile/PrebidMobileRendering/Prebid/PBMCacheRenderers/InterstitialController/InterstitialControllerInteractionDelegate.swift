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

import UIKit

/// A protocol that defines methods for handling user interactions and lifecycle events related to interstitial ads.
@objc
public protocol InterstitialControllerInteractionDelegate: NSObjectProtocol {

    /// Tracks an impression for the specified interstitial ad controller.
    ///
    /// - Parameters:
    ///    - forInterstitialController: The interstitial ad controller associated with the impression.
    @objc func trackImpression(
        forInterstitialController: PrebidMobileInterstitialControllerProtocol
    )

    /// Notifies that the interstitial ad was clicked by the user.
    ///
    /// - Parameters:
    ///    -  interstitialController: The interstitial ad controller associated with the click.
    @objc func interstitialControllerDidClickAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )
    
    /// Notifies the delegate that the interstitial ad has been closed by the user.
    ///
    /// - Parameters:
    ///    - interstitialController: The interstitial ad controller that was closed.
    @objc func interstitialControllerDidCloseAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )
    
    /// Notifies the delegate that the user has left the app after interacting with the interstitial ad.
    ///
    /// - Parameters:
    ///    - interstitialController: The interstitial ad controller that was displayed when the user left the app.
    @objc func interstitialControllerDidLeaveApp(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )
    
    /// Notifies the delegate that the interstitial ad has been displayed to the user.
    ///
    /// - Parameters:
    ///    - interstitialController: The interstitial ad controller that displayed the ad.
    @objc func interstitialControllerDidDisplay(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )
    
    /// Notifies the delegate that the interstitial ad has completed its presentation.
    ///
    /// - Parameters:
    ///    - interstitialController: The interstitial ad controller associated with the completed ad.
    @objc func interstitialControllerDidComplete(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    )

    /// Requests the `UIViewController` to be used for presenting modals from the interstitial ad controller.
    ///
    /// - Parameters:
    ///    - fromInterstitialController: The interstitial ad controller requesting the view controller.
    @objc func viewControllerForModalPresentation(
        fromInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) -> UIViewController?
    
    /// Notifies the delegate when a reward is granted to the user after interacting with a rewarded interstitial ad.
    ///
    /// - Parameters:
    ///   - interstitialController: The instance of the interstitial ad controller responsible for managing the ad.
    ///   - reward: An object containing details about the reward, such as the type and amount.
    @objc optional func trackUserReward(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        _ reward: PrebidReward
    )
}

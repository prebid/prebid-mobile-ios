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

/// A protocol for handling events related to rewarded ads.
///
/// This protocol extends `PBMInterstitialAd` and defines properties for delegates that handle events related to the ad server communication and user interactions with rewarded ads. Implementing this protocol allows for custom handling of these events within the rewarded ad lifecycle.
@objc public protocol RewardedEventHandlerProtocol: PBMInterstitialAd {

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
    weak var loadingDelegate: InterstitialEventLoadingDelegate? { get set }

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
    weak var interactionDelegate: RewardedEventInteractionDelegate? { get set }
}

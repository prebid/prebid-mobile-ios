/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

/// A protocol for the plugin renderer, defining the basic interface that any renderer should implement.
/// This protocol provides the ability to retrieve plugin details, support rendering formats, and manage event delegates and
/// methods for creating custom banner view and insterstitial controller.
@objc
public protocol PrebidMobilePluginRenderer: AnyObject {
    
    /// The name of the plugin renderer. This is used to identify the plugin.
    @objc var name: String { get }
    
    /// The version of the plugin renderer.
    @objc var version: String { get }
    
    /// Custom data to be included in the ORTB request.
    @objc var data: [String: Any]? { get }
    
    /// Register a listener related to a specific ad unit config fingerprint in order to dispatch specific ad events.
    @objc optional func registerEventDelegate(
        pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    )
    
    /// Unregister a listener related to a specific ad unit config fingerprint in order to dispatch specific ad events.
    @objc optional func unregisterEventDelegate(
        pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    )
    
    /// Creates and returns an ad view conforming to `PrebidMobileDisplayViewManagerProtocol` for a given bid response.
    /// Returns nil in the case of an internal error or if no renderer is provided.
    ///
    /// - Parameters:
    ///   - frame: The frame specifying the initial size and position of the ad view.
    ///   - bid: The `Bid` object containing the bid response used for rendering the ad.
    ///   - adConfiguration: The `AdUnitConfig` instance providing configuration details for the ad unit.
    ///   - loadingDelegate: The delegate conforming to `DisplayViewLoadingDelegate` for handling ad loading events.
    ///   - interactionDelegate: The  delegate conforming to `DisplayViewInteractionDelegate` for handling ad interaction events.
    @objc func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)?
    
    /// Creates and returns an implementation of `PrebidMobileInterstitialControllerProtocol` for a given bid response.
    /// Returns nil in the case of an internal error or if no renderer is provided.
    ///
    /// - Parameters:
    ///   - bid: The `Bid` object containing the bid response used for rendering the interstitial ad.
    ///   - adConfiguration: The `AdUnitConfig` instance providing configuration details for the ad unit.
    ///   - loadingDelegate: The delegate for handling interstitial ad loading events.
    ///   - interactionDelegate: The delegate for handling user interactions with the interstitial ad.
    @objc func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol?
}

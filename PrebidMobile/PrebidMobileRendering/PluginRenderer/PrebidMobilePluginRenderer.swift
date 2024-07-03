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

@objc public protocol PrebidMobilePluginRenderer: AnyObject {
    
    @objc var name: String { get }
    @objc var version: String { get }
    @objc var data: [AnyHashable: Any]? { get }
    
    /// Creates and returns Banner View for a given Bid Response
    /// Returns nil in the case of an internal error
    @objc func createBannerAdView(with frame: CGRect, bid: Bid, adConfiguration: AdUnitConfig, connection: PrebidServerConnectionProtocol, adViewDelegate: (any PBMAdViewDelegate)?)
    
    /// Creates and returns an implementation of PrebidMobileInterstitialControllerInterface for a given bid response
    /// Returns nil in the case of an internal error
    @objc optional func createInterstitialController( bid: Bid, adConfiguration: AdUnitConfig, connection: PrebidServerConnectionProtocol, adViewManagerDelegate: InterstitialController?, videoControlsConfig: VideoControlsConfiguration?)

    /// Returns true only if the given ad unit could be renderer by the plugin
    @objc func isSupportRendering(for format: AdFormat?) -> Bool
    
    /// Register a listener related to a specific ad unit config fingerprint in order to dispatch specific ad events
    @objc optional func registerEventDelegate(pluginEventDelegate: PluginEventDelegate, adUnitConfigFingerprint: String)

    /// Unregister a listener related to a specific ad unit config fingerprint in order to dispatch specific ad events
    @objc optional func unregisterEventDelegate(pluginEventDelegate: PluginEventDelegate, adUnitConfigFingerprint: String)
    
    /// Setup a bid for a given ad unit configuration
    @objc func setupBid(_ bid: PrebidMobile.Bid, adConfiguration: PrebidMobile.AdUnitConfig, connection: PrebidServerConnectionProtocol)

    
    
}

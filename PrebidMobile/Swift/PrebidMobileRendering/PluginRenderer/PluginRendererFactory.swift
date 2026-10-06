/*   Copyright 2018-2025 Prebid.org, Inc.

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

/// A factory that resolves the appropriate plugin renderer for a given bid
/// and creates banner views or interstitial controllers through it.
///
/// Callers should prepare the `AdUnitConfig` before invoking this factory. The
/// factory only handles renderer resolution and SDK-renderer fallback, so
/// caller-owned configuration such as banner size, interstitial flags, rewarded
/// flags, video controls, and video parameters is preserved.
///
/// When a plugin renderer creates the ad, the factory sends the win notice for the bid:
/// `nurl`, the Prebid Cache URLs and `ext.prebid.events.win`. It skips the notice when the
/// renderer reports `sendsWinNotice` as `true`. Prebid's own `DisplayView` and
/// `InterstitialController` send it themselves when they load.
@objcMembers
public class PluginRendererFactory: NSObject {

    /// Creates a banner view using a caller-prepared ad unit configuration.
    ///
    /// - Parameters:
    ///   - frame: The frame for the banner view.
    ///   - bid: The bid containing renderer preference metadata.
    ///   - adConfiguration: Prepared ad unit configuration.
    ///   - loadingDelegate: Delegate for ad loading events.
    ///   - interactionDelegate: Delegate for ad interaction events.
    /// - Returns: A banner view conforming to `PrebidMobileDisplayViewProtocol`, or `nil` on failure.
    public static func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate,
            connection: PrebidServerConnection.shared
        )
    }

    static func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate,
        connection: PrebidServerConnectionProtocol
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        let renderer = PrebidMobilePluginRegister.shared.getPluginForPreferredRenderer(bid: bid)
        Log.info("PluginRendererFactory banner renderer: \(renderer.name)")

        if let view = renderer.createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        ) {
            // `DisplayView.loadAd()` sends the win notice itself.
            if !(view is DisplayView) {
                notifyWin(for: bid, renderedBy: renderer, connection: connection)
            }
            return view
        }

        Log.warn("Preferred renderer returned nil for banner. Falling back to SDK default renderer.")
        let fallbackRenderer = PrebidMobilePluginRegister.shared.sdkRenderer
        return fallbackRenderer.createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    /// Creates an interstitial controller using a caller-prepared ad unit configuration.
    ///
    /// - Parameters:
    ///   - bid: The bid containing renderer preference metadata.
    ///   - adConfiguration: Prepared ad unit configuration.
    ///   - loadingDelegate: Delegate for interstitial loading events.
    ///   - interactionDelegate: Delegate for interstitial interaction events.
    /// - Returns: An interstitial controller conforming to `PrebidMobileInterstitialControllerProtocol`, or `nil` on failure.
    public static func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate,
            connection: PrebidServerConnection.shared
        )
    }

    static func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate,
        connection: PrebidServerConnectionProtocol
    ) -> PrebidMobileInterstitialControllerProtocol? {
        let renderer = PrebidMobilePluginRegister.shared.getPluginForPreferredRenderer(bid: bid)
        Log.info("PluginRendererFactory interstitial renderer: \(renderer.name)")

        if let controller = renderer.createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        ) {
            // `InterstitialController.loadAd()` sends the win notice itself.
            if !(controller is InterstitialController) {
                notifyWin(for: bid, renderedBy: renderer, connection: connection)
            }
            return controller
        }

        Log.warn("Preferred renderer returned nil for interstitial. Falling back to SDK default renderer.")
        let fallbackRenderer = PrebidMobilePluginRegister.shared.sdkRenderer
        return fallbackRenderer.createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    // MARK: - Private

    /// Sends the win notice for an ad that a plugin renderer draws.
    ///
    /// Prebid's own renderer sends `nurl` and the Prebid Cache URLs through `WinNotifier`
    /// when its view or controller loads, and `ext.prebid.events.win` from its creative.
    /// A plugin renderer replaces both, so nothing else sends the notice for its ad,
    /// unless the renderer reports that it sends the notice itself.
    /// The ad is created only after Prebid wins, so the requests are fire and forget.
    private static func notifyWin(
        for bid: Bid,
        renderedBy renderer: PrebidMobilePluginRenderer,
        connection: PrebidServerConnectionProtocol
    ) {
        guard renderer.sendsWinNotice != true else {
            Log.info("\(renderer.name) sends the win notice itself. Prebid does not send it.")
            return
        }

        Factory.WinNotifierType.notifyThroughConnection(connection, winningBid: bid) { _ in }

        if let winURL = bid.events?.win {
            connection.fireAndForget(winURL)
        }
    }
}

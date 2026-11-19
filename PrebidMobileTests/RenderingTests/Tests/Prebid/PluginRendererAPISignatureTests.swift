/*   Copyright 2018-2026 Prebid.org, Inc.

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
import XCTest
import PrebidMobile

// This file pins the exact shape of the Plugin Renderer public API (the extension point used
// by third-party renderers such as MAX/AdMob adapters, see #1287) as a compile-time contract.
// Each reference type below only needs to conform to its protocol to make the whole test target
// fail to build the moment a *required* member's signature is narrowed, widened, or otherwise
// changed - conformance itself is the check, no runtime construction is needed.
//
// `@objc optional` requirements are different: Swift does not enforce their signature via
// conformance. If an optional requirement's type drifts, an implementation that still uses the
// old signature merely becomes a "nearly matches optional requirement" warning, not an error -
// the type still conforms because the requirement was never mandatory. To make a signature
// change on those members a hard compile error too, each optional member is read back through
// its *protocol-typed* existential into an explicitly-typed constant near the bottom of this
// file: the assignment only type-checks if the protocol's declared type still matches.
//
// If you are forced to touch this file to make it compile again, the signature change you are
// making is a breaking API change and requires a major version bump.

private final class PluginRendererSignatureContract: NSObject, PrebidMobilePluginRenderer {

    // Breaking change requires a major version bump.
    let name = ""

    // Breaking change requires a major version bump.
    let version = ""

    // Breaking change requires a major version bump.
    var data: [String: Any]?

    // Breaking change requires a major version bump. This requirement is `@objc optional`;
    // its signature is additionally pinned below via the protocol existential.
    func registerEventDelegate(
        pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {}

    // Breaking change requires a major version bump. This requirement is `@objc optional`;
    // its signature is additionally pinned below via the protocol existential.
    func unregisterEventDelegate(
        pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {}

    // Breaking change requires a major version bump. Regressed in 3.3.2 (#1287) when the return
    // type was narrowed from `(UIView & PrebidMobileDisplayViewProtocol)?` to `PrebidMobileDisplayViewProtocol?`.
    func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        nil
    }

    // Breaking change requires a major version bump.
    func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        nil
    }

    // Breaking change requires a major version bump. This requirement is `@objc optional`;
    // its signature is additionally pinned below via the protocol existential.
    func didInjectView(_ view: UIView, into bannerView: UIView) {}
}

private final class DisplayViewSignatureContract: UIView, PrebidMobileDisplayViewProtocol {
    // Breaking change requires a major version bump.
    func loadAd() {}
}

private final class InterstitialControllerSignatureContract: NSObject, PrebidMobileInterstitialControllerProtocol {
    // Breaking change requires a major version bump.
    func loadAd() {}

    // Breaking change requires a major version bump.
    func show() {}
}

private final class PluginEventDelegateSignatureContract: NSObject, PluginEventDelegate {
    // Breaking change requires a major version bump.
    func getPluginName() -> String { "" }
}

private final class DisplayViewLoadingDelegateSignatureContract: NSObject, DisplayViewLoadingDelegate {
    // Breaking change requires a major version bump.
    func displayViewDidLoadAd(_ displayView: UIView) {}

    // Breaking change requires a major version bump.
    func displayView(_ displayView: UIView, didFailWithError error: Error) {}
}

private final class DisplayViewInteractionDelegateSignatureContract: NSObject, DisplayViewInteractionDelegate {
    // Breaking change requires a major version bump.
    func trackImpression(forDisplayView: UIView) {}

    // Breaking change requires a major version bump.
    func didLeaveApp(from displayView: UIView) {}

    // Breaking change requires a major version bump.
    func willPresentModal(from displayView: UIView) {}

    // Breaking change requires a major version bump.
    func didDismissModal(from displayView: UIView) {}

    // Breaking change requires a major version bump.
    func viewControllerForModalPresentation(fromDisplayView: UIView) -> UIViewController? { nil }
}

private final class InterstitialControllerLoadingDelegateSignatureContract: NSObject, InterstitialControllerLoadingDelegate {
    // Breaking change requires a major version bump.
    func interstitialControllerDidLoadAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    ) {}
}

private final class InterstitialControllerInteractionDelegateSignatureContract: NSObject, InterstitialControllerInteractionDelegate {
    // Breaking change requires a major version bump.
    func trackImpression(
        forInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialControllerDidClickAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialControllerDidCloseAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialControllerDidLeaveApp(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialControllerDidDisplay(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func interstitialControllerDidComplete(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {}

    // Breaking change requires a major version bump.
    func viewControllerForModalPresentation(
        fromInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) -> UIViewController? { nil }

    // Breaking change requires a major version bump. This requirement is `@objc optional`;
    // its signature is additionally pinned below via the protocol existential.
    func trackUserReward(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        _ reward: PrebidReward
    ) {}
}

// MARK: - Optional requirement signature pins
//
// Reading each `@objc optional` member back through its protocol existential (rather than the
// concrete contract type above) forces the compiler to check the assignment against the
// *protocol's* declared type. If a maintainer narrows/widens/retypes one of these four members,
// this assignment fails to compile even though the concrete type above would still silently
// "conform" (optional requirements are never enforced by conformance checking).
//
// Both underlying instances are plain `NSObject` subclasses, so producing them is cheap - no
// `UIView`/UIKit runtime setup is triggered, unlike constructing a `UIView` in a test process.

private let pluginRendererContract: PrebidMobilePluginRenderer = PluginRendererSignatureContract()

private let pluginRendererOptionalRegisterEventDelegate: ((PluginEventDelegate, String) -> Void)? =
    pluginRendererContract.registerEventDelegate

private let pluginRendererOptionalUnregisterEventDelegate: ((PluginEventDelegate, String) -> Void)? =
    pluginRendererContract.unregisterEventDelegate

private let pluginRendererOptionalDidInjectView: ((UIView, UIView) -> Void)? =
    pluginRendererContract.didInjectView

private let interstitialInteractionContract: InterstitialControllerInteractionDelegate =
    InterstitialControllerInteractionDelegateSignatureContract()

private let interstitialInteractionOptionalTrackUserReward:
    ((PrebidMobileInterstitialControllerProtocol, PrebidReward) -> Void)? =
        interstitialInteractionContract.trackUserReward

/// Fails to COMPILE if any Plugin Renderer protocol signature changes (see #1287, #1291).
final class PluginRendererAPISignatureTests: XCTestCase {

    /// Required (non-optional) protocol members are already pinned purely by the reference
    /// conformance types above compiling - no runtime construction is needed to verify them.
    /// This test only confirms the four `@objc optional` members were successfully bound through
    /// their protocol existentials above, i.e. none of their signatures has silently changed.
    func testOptionalRequirementsArePinned() {
        XCTAssertNotNil(pluginRendererOptionalRegisterEventDelegate)
        XCTAssertNotNil(pluginRendererOptionalUnregisterEventDelegate)
        XCTAssertNotNil(pluginRendererOptionalDidInjectView)
        XCTAssertNotNil(interstitialInteractionOptionalTrackUserReward)
    }
}

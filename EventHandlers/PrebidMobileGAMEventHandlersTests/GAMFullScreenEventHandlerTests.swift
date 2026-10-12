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

import XCTest
import GoogleMobileAds
import PrebidMobile
@testable import PrebidMobileGAMEventHandlers

// The ad unit blocks show(from:) from the moment it presents an ad until the event handler
// reports didDismissAd, so every way a GAM-rendered ad ends must reach the interaction delegate.
@MainActor
final class GAMFullScreenEventHandlerTests: XCTestCase {

    private let adUnitID = "/test/adunit"

    // MARK: - GAMInterstitialEventHandler

    func testInterstitialDismissIsReportedToInteractionDelegate() {
        let handler = GAMInterstitialEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.adDidDismissFullScreenContent(DummyFullScreenAd())

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    func testInterstitialPresentFailureIsReportedAsDismiss() {
        let handler = GAMInterstitialEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.ad(DummyFullScreenAd(), didFailToPresentFullScreenContentWithError: NSError(domain: "test", code: 1))

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    func testInterstitialShowWithoutLoadedAdIsReportedAsDismiss() {
        let handler = GAMInterstitialEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.show(from: UIViewController())

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    // MARK: - GAMRewardedAdEventHandler

    func testRewardedDismissIsReportedToInteractionDelegate() {
        let handler = GAMRewardedAdEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.adDidDismissFullScreenContent(DummyFullScreenAd())

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    func testRewardedPresentFailureIsReportedAsDismiss() {
        let handler = GAMRewardedAdEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.ad(DummyFullScreenAd(), didFailToPresentFullScreenContentWithError: NSError(domain: "test", code: 1))

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    func testRewardedShowWithoutLoadedAdIsReportedAsDismiss() {
        let handler = GAMRewardedAdEventHandler(adUnitID: adUnitID)
        let interactionDelegate = MockInteractionDelegate()
        handler.interactionDelegate = interactionDelegate

        handler.show(from: UIViewController())

        XCTAssertEqual(interactionDelegate.didDismissAdCount, 1)
    }

    func testRewardedRequestAfterAdServerWinStartsNewRequest() {
        let handler = GAMRewardedAdEventHandler(adUnitID: adUnitID)
        handler.embeddedRewarded = GADRewardedAdWrapper(adUnitID: adUnitID)

        handler.requestAd(with: nil)

        XCTAssertNotNil(handler.requestRewarded, "A loaded ad must not block the next request")
        XCTAssertNil(handler.embeddedRewarded)
        XCTAssertNil(handler.proxyRewarded)
        XCTAssertFalse(handler.isReady)
    }

    func testRewardedRequestAfterPrebidWinStartsNewRequest() {
        let handler = GAMRewardedAdEventHandler(adUnitID: adUnitID)
        handler.proxyRewarded = GADRewardedAdWrapper(adUnitID: adUnitID)

        handler.requestAd(with: nil)

        XCTAssertNotNil(handler.requestRewarded, "A loaded ad must not block the next request")
        XCTAssertNil(handler.embeddedRewarded)
        XCTAssertNil(handler.proxyRewarded)
        XCTAssertFalse(handler.isReady)
    }
}

private class DummyFullScreenAd: NSObject, GoogleMobileAds.FullScreenPresentingAd {
    weak var fullScreenContentDelegate: GoogleMobileAds.FullScreenContentDelegate?
}

private class MockInteractionDelegate: NSObject, RewardedEventInteractionDelegate {
    private(set) var didDismissAdCount = 0

    func willPresentAd() {}
    func didDismissAd() { didDismissAdCount += 1 }
    func willLeaveApp() {}
    func didClickAd() {}
    func userDidEarnReward(_ reward: PrebidReward?) {}
}

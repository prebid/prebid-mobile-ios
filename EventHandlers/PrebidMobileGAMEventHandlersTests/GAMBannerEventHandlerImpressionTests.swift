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

final class GAMBannerEventHandlerImpressionTests: XCTestCase {

    private final class BannerViewWrapperSpy: GAMBannerViewWrapper {
        var recordImpressionCount = 0
        override func recordImpression() { recordImpressionCount += 1 }
    }

    private final class LoadingDelegateSpy: NSObject, BannerEventLoadingDelegate {
        var adServerDidWinCount = 0
        func prebidDidWin() {}
        func adServerDidWin(_ view: UIView, adSize: CGSize) { adServerDidWinCount += 1 }
        func failedWithError(_ error: Error?) {}
    }

    private var handler: GAMBannerEventHandler!
    private var banner: BannerViewWrapperSpy!
    private var loadingDelegate: LoadingDelegateSpy!

    override func setUp() {
        super.setUp()
        handler = GAMBannerEventHandler(adUnitID: "/test/adunit", validGADAdSizes: [nsValue(for: AdSizeBanner)])
        banner = BannerViewWrapperSpy()
        loadingDelegate = LoadingDelegateSpy()
        handler.loadingDelegate = loadingDelegate
        handler.requestBanner = banner
        // `dfpAdSize` falls back to `requestBanner`, which is cleared before it is read.
        handler.lastGADSize = CGSize(width: 320, height: 50)
    }

    func testAdServerWinWithoutBidRecordsImpressionOnceOnScreen() {
        handler.isExpectingAppEvent = false
        handler.primaryAdReceived()

        XCTAssertEqual(loadingDelegate.adServerDidWinCount, 1)
        XCTAssertEqual(banner.recordImpressionCount, 0)

        handler.bannerViewDidRecordImpression(banner.banner)
        XCTAssertEqual(banner.recordImpressionCount, 1)
    }

    func testAppEventTimeoutRecordsImpressionOnceOnScreen() {
        handler.isExpectingAppEvent = true
        handler.appEventTimedOut()

        XCTAssertEqual(loadingDelegate.adServerDidWinCount, 1)
        XCTAssertEqual(banner.recordImpressionCount, 0)

        handler.bannerViewDidRecordImpression(banner.banner)
        XCTAssertEqual(banner.recordImpressionCount, 1)
    }

    func testPrebidWinRecordsOnlyOnTrackImpression() {
        handler.isExpectingAppEvent = true
        handler.appEventDetected()

        handler.bannerViewDidRecordImpression(banner.banner)
        XCTAssertEqual(banner.recordImpressionCount, 0)

        handler.trackImpression()
        XCTAssertEqual(banner.recordImpressionCount, 1)
    }
}

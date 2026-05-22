/*   Copyright 2018-2021 Prebid.org, Inc.

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
import UIKit

@testable @_spi(PBMInternal) import PrebidMobile

class MockBannerView: BannerView {
    override var lastBidResponse: BidResponse? {
        return WinningBidResponseFabricator.makeWinningBidResponse(bidPrice: 0.85)
    }
}

@objc class TestBannerDelegate: NSObject, BannerViewDelegate {
    let exp: XCTestExpectation?
    let expireExp: XCTestExpectation?
    var onExpire: ((BannerView) -> Void)?
    var failCallCount = 0

    init(exp: XCTestExpectation? = nil, expireExp: XCTestExpectation? = nil) {
        self.exp = exp
        self.expireExp = expireExp
    }

    func bannerViewPresentationController() -> UIViewController? {
        return nil
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
        failCallCount += 1

        guard let exp else { return }
        XCTAssertEqual(error as NSError?, PBMError.prebidInvalidAccountId() as NSError?)
        XCTAssertNotNil(bannerView.lastBidResponse)
        exp.fulfill()
    }

    func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize) {
        XCTFail("Ad unexpectedly loaded successfully...")
        exp?.fulfill()
    }

    func bannerViewDidExpire(_ bannerView: BannerView) {
        onExpire?(bannerView)
        expireExp?.fulfill()
    }
}

class TestAdLoadFlowController: AdLoadFlowController {
    var refreshCallCount = 0
    var refreshHandler: (() -> Void)?

    convenience init(adUnitConfig: AdUnitConfig) {
        self.init(
            bidRequesterFactory: { _ in TestBidRequester() },
            adLoader: TestAdLoader(),
            adUnitConfig: adUnitConfig,
            delegate: TestAdLoadFlowControllerDelegate(),
            configValidationBlock: { _, _ in true }
        )
    }

    required init(
        bidRequesterFactory: @escaping (AdUnitConfig) -> BidRequesterProtocol,
        adLoader: AdLoaderProtocol,
        adUnitConfig: AdUnitConfig,
        delegate: AdLoadFlowControllerDelegate,
        configValidationBlock: @escaping AdUnitConfigValidationBlock
    ) {
        super.init(
            bidRequesterFactory: bidRequesterFactory,
            adLoader: adLoader,
            adUnitConfig: adUnitConfig,
            delegate: delegate,
            configValidationBlock: configValidationBlock
        )
    }

    override func refresh() {
        refreshCallCount += 1
        refreshHandler?()
    }
}

class TestBidRequester: NSObject, BidRequesterProtocol {
    func requestBids(completion: @escaping (BidResponse?, Error?) -> Void) {}
}

class TestAdLoader: NSObject, AdLoaderProtocol {
    weak var flowDelegate: AdLoaderFlowDelegate?
    var primaryAdRequester: PrimaryAdRequesterProtocol? { nil }

    func createPrebidAd(
        with bid: Bid,
        adUnitConfig: AdUnitConfig,
        adObjectSaver: @escaping (AnyObject) -> Void,
        loadMethodInvoker: @escaping (@escaping VoidBlock) -> Void
    ) {}

    func reportSuccess(with adObject: AnyObject, adSize: NSValue?) {}
}

class TestAdLoadFlowControllerDelegate: NSObject, AdLoadFlowControllerDelegate {
    func adLoadFlowController(_ adLoadFlowController: AdLoadFlowController, failedWithError error: Error?) {}
    func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: AdLoadFlowController) {}
    func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: AdLoadFlowController) {}
    func adLoadFlowControllerShouldContinue(_ adLoadFlowController: AdLoadFlowController) -> Bool { true }
}

@objc class TestBannerViewVideoPlaybackDelegate: NSObject, BannerViewVideoPlaybackDelegate {
    struct BannerViewVideoPlaybackDelegateEvents: OptionSet {
        let rawValue: Int8

        static let pause = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 0)
        static let resume = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 1)
        static let mute = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 2)
        static let unmute = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 3)
        static let complete = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 4)
    }

    var events: BannerViewVideoPlaybackDelegateEvents = []

    func videoPlaybackDidPause(_ banner: PrebidMobile.BannerView) {
        events.insert(.pause)
    }

    func videoPlaybackDidResume(_ banner: PrebidMobile.BannerView) {
        events.insert(.resume)
    }

    func videoPlaybackWasMuted(_ banner: PrebidMobile.BannerView) {
        events.insert(.mute)
    }

    func videoPlaybackWasUnmuted(_ banner: PrebidMobile.BannerView) {
        events.insert(.unmute)
    }

    func videoPlaybackDidComplete(_ banner: PrebidMobile.BannerView) {
        events.insert(.complete)
    }
}

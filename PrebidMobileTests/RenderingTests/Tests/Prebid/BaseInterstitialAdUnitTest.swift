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

import XCTest
import UIKit
@testable @_spi(PBMInternal) import PrebidMobile

class BaseInterstitialAdUnitTest: XCTestCase {

    func testCloseButtonArea() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        let videoConfig = adUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = 1.1
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = -0.1
        XCTAssertTrue(videoConfig.closeButtonArea == 0.1)
        
        videoConfig.closeButtonArea = 0.25
        XCTAssertTrue(videoConfig.closeButtonArea == 0.25)
    }
    
    func testCloseButtonPosition() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        let videoConfig = adUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertEqual(videoConfig.closeButtonPosition, .topRight)
        
        videoConfig.closeButtonPosition = .topLeft
        XCTAssertEqual(videoConfig.closeButtonPosition, .topLeft)
    }
    
    func testInterstitialControllerExpiresLoadedAd() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let bid = Bid(bid: rawBid)
        let controller = InterstitialController(bid: bid, configId: "test")
        controller.adViewManager = TestAdViewManager()
        let expirationExpectation = expectation(description: "Interstitial expiration callback")
        let loadingDelegate = InterstitialExpirationLoadingDelegate(expirationExpectation: expirationExpectation)
        loadingDelegate.onExpire = { interstitialController in
            let controller = interstitialController as? InterstitialController
            XCTAssertTrue(controller?.isExpired == true)
            XCTAssertNotNil(controller?.adViewManager)
        }
        controller.loadingDelegate = loadingDelegate
        
        controller.reportSuccess()
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(controller.isExpired)
    }
    
    func testInterstitialControllerDoesNotExpireAfterDisplay() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let bid = Bid(bid: rawBid)
        let controller = InterstitialController(bid: bid, configId: "test")
        let adViewManager = TestAdViewManager()
        controller.adViewManager = adViewManager
        let expirationExpectation = expectation(description: "Displayed interstitial should not expire")
        expirationExpectation.isInverted = true
        let loadingDelegate = InterstitialExpirationLoadingDelegate(expirationExpectation: expirationExpectation)
        controller.loadingDelegate = loadingDelegate
        
        controller.reportSuccess()
        controller.show()
        controller.adDidDisplay()
        
        let stateExpectation = expectation(description: "Displayed interstitial keeps ad manager")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertFalse(controller.isExpired)
            XCTAssertTrue(adViewManager.showCalled)
            XCTAssertNotNil(controller.adViewManager)
            stateExpectation.fulfill()
        }
        wait(for: [expirationExpectation, stateExpectation], timeout: 1.0)
    }
    
    func testInterstitialControllerShowAfterExpirationStillShows() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let bid = Bid(bid: rawBid)
        let controller = InterstitialController(bid: bid, configId: "test")
        let adViewManager = TestAdViewManager()
        controller.adViewManager = adViewManager
        
        controller.reportSuccess()
        
        let expirationExpectation = expectation(description: "Interstitial expires before show")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertTrue(controller.isExpired)
            controller.show()
            XCTAssertTrue(adViewManager.showCalled)
            expirationExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testInterstitialControllerWithoutExpirationDoesNotExpire() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        let bid = Bid(bid: rawBid)
        let controller = InterstitialController(bid: bid, configId: "test")
        let expirationExpectation = expectation(description: "Interstitial stays unexpired")
        
        controller.reportSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertFalse(controller.isExpired)
            expirationExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testDisplayViewExpiresLoadedAdAndNotifiesDelegate() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let displayView = DisplayView(
            frame: .zero,
            bid: Bid(bid: rawBid),
            adConfiguration: AdUnitConfig(configId: "test", size: .zero)
        )
        let expectation = expectation(description: "DisplayView expiration callback")
        let delegate = DisplayViewExpirationDelegate(expirationExpectation: expectation)
        delegate.onExpire = { displayView in
            let displayView = displayView as? DisplayView
            XCTAssertTrue(displayView?.isExpired == true)
            XCTAssertNotNil(displayView?.adViewManager)
        }
        displayView.loadingDelegate = delegate
        displayView.adViewManager = TestAdViewManager()
        
        displayView.adLoaded(AdDetails(rawResponse: "", transactionId: ""))
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(displayView.isExpired)
    }
    
    func testDisplayViewLoadAdAfterExpirationDoesNothingForAlreadyLoadedAd() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let displayView = DisplayView(
            frame: .zero,
            bid: Bid(bid: rawBid),
            adConfiguration: AdUnitConfig(configId: "test", size: .zero)
        )
        
        displayView.adLoaded(AdDetails(rawResponse: "", transactionId: ""))
        
        let expirationExpectation = expectation(description: "DisplayView expires before loadAd")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertTrue(displayView.isExpired)
            displayView.loadAd()
            XCTAssertNil(displayView.transactionFactory)
            expirationExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testDisplayViewDoesNotExpireAfterImpressionTracked() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.exp = 0.3
        let displayView = DisplayView(
            frame: .zero,
            bid: Bid(bid: rawBid),
            adConfiguration: AdUnitConfig(configId: "test", size: .zero)
        )
        let expirationExpectation = expectation(description: "Displayed DisplayView should not expire")
        expirationExpectation.isInverted = true
        let loadingDelegate = DisplayViewExpirationDelegate(expirationExpectation: expirationExpectation)
        displayView.loadingDelegate = loadingDelegate
        displayView.adViewManager = TestAdViewManager()
        
        displayView.adLoaded(AdDetails(rawResponse: "", transactionId: ""))
        displayView.adDidDisplay()
        
        let stateExpectation = expectation(description: "Displayed DisplayView keeps ad manager")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertFalse(displayView.isExpired)
            XCTAssertNotNil(displayView.adViewManager)
            stateExpectation.fulfill()
        }
        wait(for: [expirationExpectation, stateExpectation], timeout: 1.0)
    }
    
    func testDisplayViewWithoutExpirationDoesNotExpire() {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        let displayView = DisplayView(
            frame: .zero,
            bid: Bid(bid: rawBid),
            adConfiguration: AdUnitConfig(configId: "test", size: .zero)
        )
        let expirationExpectation = expectation(description: "DisplayView stays unexpired")
        
        displayView.adLoaded(AdDetails(rawResponse: "", transactionId: ""))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XCTAssertFalse(displayView.isExpired)
            expirationExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testBaseInterstitialAdUnitExpiresLoadedAdAndKeepsReadyAndShow() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        let delegate = BaseInterstitialDelegate()
        let expireExpectation = expectation(description: "Public interstitial expiration delegate")
        delegate.expireExpectation = expireExpectation
        adUnit.delegate = delegate
        var showCalled = false
        
        adUnit.interstitialAdLoader(
            InterstitialAdLoader(delegate: adUnit, eventHandler: InterstitialEventHandlerStandalone()),
            loadedAd: { _ in showCalled = true },
            isReadyBlock: { true }
        )
        
        XCTAssertTrue(adUnit.isReady)
        
        adUnit.interstitialAdLoaderAdDidExpire(
            InterstitialAdLoader(delegate: adUnit, eventHandler: InterstitialEventHandlerStandalone())
        )
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(adUnit.isReady)
        
        adUnit.show(from: UIViewController())
        XCTAssertTrue(showCalled)
    }
    

    // The same ad unit must show a new ad after the previous one was shown and closed:
    // load, show, close, load, show. Closes from Prebid's renderer and plugin renderers
    // arrive through interstitialControllerDidCloseAd.
    func testShowAfterCloseShowsTheNextAdOnTheSameAdUnit() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "test",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        let delegate = BaseInterstitialDelegate()
        adUnit.delegate = delegate
        let adLoader = InterstitialAdLoader(delegate: adUnit, eventHandler: InterstitialEventHandlerStandalone())
        var firstAdShows = 0
        var secondAdShows = 0

        adUnit.interstitialAdLoader(adLoader, loadedAd: { _ in firstAdShows += 1 }, isReadyBlock: { true })
        adUnit.show(from: UIViewController())
        adUnit.interstitialControllerDidCloseAd(MockInterstitialController())

        adUnit.interstitialAdLoader(adLoader, loadedAd: { _ in secondAdShows += 1 }, isReadyBlock: { true })
        XCTAssertTrue(adUnit.isReady)
        adUnit.show(from: UIViewController())

        XCTAssertEqual(firstAdShows, 1)
        XCTAssertEqual(secondAdShows, 1, "show(from:) after a close must show the next ad")
    }

    // MARK: - Server-side video controls

    // The bid response can carry `ext.prebid.passthrough[].adconfiguration`. Those values belong to
    // the bid that carries them: the controller applies them to its own copy of the ad unit's config,
    // so the ad unit keeps whatever the app set and the next ad starts from the app's settings.
    func testServerSideVideoControlsApplyToTheirBidOnly() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        adUnit.isMuted = true
        adUnit.skipDelay = 5

        // Ad 1: the server asks for sound, a 15 s cap and a 2 s skip delay
        let soundOn = InterstitialController(
            bid: makeBid(type: "video", serverControls: makeServerControls(isMuted: false, maxVideoDuration: 15, skipDelay: 2)),
            adConfiguration: adUnit.adUnitConfig
        )
        soundOn.loadAd()
        XCTAssertEqual(soundOn.renderedVideoControls?.isMuted, false, "ismuted=0 wins over the app's setting for this ad")
        XCTAssertEqual(soundOn.renderedVideoControls?.maxVideoDuration, 15)
        XCTAssertEqual(soundOn.renderedVideoControls?.skipDelay, 2)
        XCTAssertTrue(adUnit.isMuted, "The ad unit keeps the app's value")
        XCTAssertEqual(adUnit.skipDelay, 5)
        XCTAssertNil(adUnit.adUnitConfig.adConfiguration.videoControlsConfig.maxVideoDuration,
                     "Server values never land on the ad unit")

        // Ad 2: no passthrough, so the app's settings are back
        let noPassthrough = InterstitialController(bid: makeBid(type: "video"), adConfiguration: adUnit.adUnitConfig)
        noPassthrough.loadAd()
        XCTAssertEqual(noPassthrough.renderedVideoControls?.isMuted, true, "An ad without a passthrough renders with the app's setting")
        XCTAssertNil(noPassthrough.renderedVideoControls?.maxVideoDuration, "The previous ad's cap does not carry over")
        XCTAssertEqual(noPassthrough.renderedVideoControls?.skipDelay, 5, "The previous ad's skip delay does not carry over")

        XCTAssertNil(adUnit.adUnitConfig.adConfiguration.winningBidAdFormat, "Per-bid state stays off the ad unit's config")
        XCTAssertNil(adUnit.adUnitConfig.adConfiguration.rewardedConfig)
    }

    func testServerSideIsMutedLeavesTheRewardedAdUnitSettingAlone() {
        let adUnit = RewardedAdUnit(configID: "test")
        adUnit.isMuted = false

        let controller = InterstitialController(
            bid: makeBid(type: "video", serverControls: makeServerControls(isMuted: true)),
            adConfiguration: adUnit.adUnitConfig
        )
        controller.loadAd()

        XCTAssertEqual(controller.renderedVideoControls?.isMuted, true, "ismuted=1 mutes this ad")
        XCTAssertEqual(controller.renderingConfiguration?.adConfiguration.isRewarded, true, "The copy keeps the ad unit's rewarded flag")
        XCTAssertFalse(adUnit.isMuted, "The ad unit keeps the app's value")
    }

    // The copy only helps if the ad is built from it. The VAST loader rejects a creative longer than
    // the `maxVideoDuration` of the config the transaction factory was given, and the app sets no cap
    // here, so the rejection shows the factory got the copy with the server's cap. It happens before
    // any media download, so the test needs no network, web view or video player.
    func testVideoIsBuiltFromThePerBidCopy() {
        let adUnit = InterstitialRenderingAdUnit(configID: "test")
        let bid = makeBid(type: "video", adm: makeVAST(duration: "00:00:30"), serverControls: makeServerControls(maxVideoDuration: 10))
        let controller = InterstitialController(bid: bid, adConfiguration: adUnit.adUnitConfig)
        let loadingDelegate = RecordingInterstitialLoadingDelegate()
        loadingDelegate.failed = expectation(description: "The 30 s creative is rejected")
        controller.loadingDelegate = loadingDelegate

        controller.loadAd()
        waitForExpectations(timeout: 5)

        XCTAssertEqual(loadingDelegate.error?.localizedDescription,
                       "Creative duration is bigger than maximum available playback time obtained from server response.")
        XCTAssertNil(adUnit.adUnitConfig.adConfiguration.videoControlsConfig.maxVideoDuration,
                     "The cap stays on the copy")
    }

    // MARK: - Helpers

    private func makeBid(type: String, adm: String? = nil, serverControls: ORTBAdConfiguration? = nil) -> Bid {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.adm = adm
        rawBid.ext = .init()
        rawBid.ext?.prebid = .init()
        rawBid.ext?.prebid?.type = type
        if let serverControls {
            let passthrough = ORTBExtPrebidPassthrough()
            passthrough.type = "prebidmobilesdk"
            passthrough.adConfiguration = serverControls
            rawBid.ext?.prebid?.passthrough = [passthrough]
        }
        return Bid(bid: rawBid)
    }

    private func makeServerControls(isMuted: Bool? = nil, maxVideoDuration: Int? = nil, skipDelay: Double? = nil) -> ORTBAdConfiguration {
        let serverControls = ORTBAdConfiguration()
        serverControls.isMuted = isMuted.map { NSNumber(value: $0) }
        serverControls.maxVideoDuration = maxVideoDuration.map { NSNumber(value: $0) }
        serverControls.skipDelay = skipDelay.map { NSNumber(value: $0) }
        return serverControls
    }

    private func makeVAST(duration: String) -> String {
        """
        <VAST version="3.0"><Ad id="ad"><InLine><AdSystem>Prebid</AdSystem><AdTitle>Video</AdTitle>\
        <Creatives><Creative><Linear><Duration>\(duration)</Duration><MediaFiles>\
        <MediaFile delivery="progressive" type="video/mp4" width="640" height="360">https://example.com/video.mp4</MediaFile>\
        </MediaFiles></Linear></Creative></Creatives></InLine></Ad></VAST>
        """
    }
}

private class RecordingInterstitialLoadingDelegate: NSObject, InterstitialControllerLoadingDelegate {
    var failed: XCTestExpectation?
    private(set) var error: Error?

    func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        XCTFail("The ad was expected to fail to load")
    }

    func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    ) {
        self.error = error
        failed?.fulfill()
    }
}

private extension InterstitialController {
    /// The video controls the creative is rendered with, once `loadAd()` has run.
    var renderedVideoControls: VideoControlsConfiguration? {
        renderingConfiguration?.adConfiguration.videoControlsConfig
    }
}

private class BaseInterstitialDelegate: NSObject, BaseInterstitialAdUnitProtocol {
    var expireExpectation: XCTestExpectation?

    func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func callDelegate_didReceiveAd() {}
    func callDelegate_didFailToReceiveAd(with error: Error?) {}
    func callDelegate_willPresentAd() {}
    func callDelegate_didDismissAd() {}
    func callDelegate_willLeaveApplication() {}
    func callDelegate_didClickAd() {}
    func callEventHandler_isReady() -> Bool { false }
    func callEventHandler_setLoadingDelegate(_ loadingDelegate: InterstitialEventLoadingDelegate?) {}
    func callEventHandler_setInteractionDelegate() {}
    func callEventHandler_requestAd(with bidResponse: BidResponse?) {}
    func callEventHandler_show(from controller: UIViewController?) {}
    func callEventHandler_trackImpression() {}

    func callDelegate_adDidExpire() {
        expireExpectation?.fulfill()
    }
}

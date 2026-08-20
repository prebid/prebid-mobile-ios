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

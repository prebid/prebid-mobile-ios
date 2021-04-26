//
//  PBMHTMLCreativeTest_ModalManagerDelegate.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMHTMLCreativeTest_ModalManagerDelegate: PBMHTMLCreativeTest_Base {

    func testInterstitialDidLeaveApp() {
        var called = false
        self.creativeInterstitialDidLeaveAppHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }

        let state = PBMModalState(view: PBMWebView(), adConfiguration:PBMAdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.htmlCreative.modalManagerDidLeaveApp(leavingState)
                
        })
        self.htmlCreative.modalManagerDidLeaveApp(state)

        XCTAssert(called)
    }

    func testClickthroughBrowserClosedCalled() {
        self.htmlCreative.clickthroughVisible = true
        var called = false
        self.creativeClickthroughDidCloseHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }

        let state = PBMModalState(view: ClickthroughBrowserView(), adConfiguration:PBMAdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.htmlCreative.modalManagerDidLeaveApp(leavingState)
                
        })
        htmlCreative.modalManagerDidFinishPop(state)

        XCTAssert(called)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }

    func testInterstitialAdClosed() {
        var called = false
        self.creativeInterstitialDidCloseHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }

        htmlCreative.clickthroughVisible = true
        htmlCreative.setupView()

        let state = PBMModalState(view: PBMWebView(), adConfiguration:PBMAdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.htmlCreative.modalManagerDidLeaveApp(leavingState)
                
        })
        htmlCreative.modalManagerDidFinishPop(state)

        XCTAssert(called)
    }
}

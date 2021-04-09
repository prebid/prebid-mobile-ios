//
//  OXMHTMLCreativeTest_ModalManagerDelegate.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMHTMLCreativeTest_ModalManagerDelegate: OXMHTMLCreativeTest_Base {

    func testInterstitialDidLeaveApp() {
        var called = false
        self.creativeInterstitialDidLeaveAppHandler = { (creative) in
            OXMAssertEq(creative, self.htmlCreative)
            called = true
        }

        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
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
            OXMAssertEq(creative, self.htmlCreative)
            called = true
        }

        let state = OXMModalState(view: ClickthroughBrowserView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
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
            OXMAssertEq(creative, self.htmlCreative)
            called = true
        }

        htmlCreative.clickthroughVisible = true
        htmlCreative.setupView()

        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.htmlCreative.modalManagerDidLeaveApp(leavingState)
                
        })
        htmlCreative.modalManagerDidFinishPop(state)

        XCTAssert(called)
    }
}

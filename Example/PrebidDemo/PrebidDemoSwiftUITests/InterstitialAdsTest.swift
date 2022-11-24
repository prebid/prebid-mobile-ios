//
//  InterstitialAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 10.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class InterstitialAdsTest: BaseAdsTest {

    public func testInAppInterstitialAd() {
        testAd(adServer: inApp, adName: interstitial)
    }
    public func testGamOriginalInterstitialAd() {
        testAd(adServer: gam, adName: interstitial)
    }
    public func testGamRenderingInterstitialAd() {
        testAd(adServer: gamR, adName: interstitial)
    }
    public func testAdMobInterstitialAd() {
        testAd(adServer: adMobR, adName: interstitial)
    }
    
    override func checkAd(adServer: String, adName: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10),assertFailedMessage(adServer: adServer, adName: adName,reason: "Interstitial Web View is not displayed"))
        let closeButton = adServer == gam ? "Close Advertisement" : "PBMCloseButton"
        XCTAssert(app.buttons[closeButton].waitForExistence(timeout: 10), assertFailedMessage(adServer: adServer, adName: adName,reason: "Close button is not displayed"))
    }
}

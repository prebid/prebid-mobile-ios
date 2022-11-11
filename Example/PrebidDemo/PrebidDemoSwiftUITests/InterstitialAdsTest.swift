//
//  InterstitialAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 10.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class InterstitialAdsTest: BaseAdsTest {
    public func testInterstitialAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: interstitial)
        testAd(adServer: gam, adName: interstitial)
        testAd(adServer: gamR, adName: interstitial)
        testAd(adServer: adMobR, adName: interstitial)
    }
    
    override func checkAd(adServer: String, adName: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10),assertFailedMessage(adServer: adServer, adName: adName,reason: "Interstitial Web View is not displayed"))
        XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 10), assertFailedMessage(adServer: adServer, adName: adName,reason: "Close button is not displayed"))
    }
}

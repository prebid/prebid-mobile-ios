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
        testAd(testCase: testCases.inAppDisplayInterstitialCase)
    }
    public func testGamOriginalInterstitialAd() {
        testAd(testCase: testCases.gamOriginalDisplayInterstitialCase)
    }
    public func testGamRenderingInterstitialAd() {
        testAd(testCase: testCases.gamDisplayInterstitialCase)
    }
    public func testAdMobInterstitialAd() {
        testAd(testCase: testCases.adMobDisplayInterstitialCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10),assertFailedMessage(testCase: testCase,reason: "Interstitial Web View is not displayed"))
        let closeButton = testCase == testCases.gamOriginalDisplayInterstitialCase ? "Close Advertisement" : "PBMCloseButton"
        XCTAssert(app.buttons[closeButton].waitForExistence(timeout: 10), assertFailedMessage(testCase: testCase,reason: "Close button is not displayed"))
    }
}

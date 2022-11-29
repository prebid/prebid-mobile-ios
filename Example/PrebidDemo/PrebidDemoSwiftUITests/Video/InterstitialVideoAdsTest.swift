//
//  InterstitialVideoAds.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 28.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import Foundation
import XCTest

class InterstitialVideoAds: BaseAdsTest {
    
    public func testInAppVideoInterstitialAd() {
        testAd(testCase: testCases.inAppVideoInterstitialCase)
    }
    public func testGamOriginalVideoInterstitialAd() {
        testAd(testCase: testCases.gamOriginalVideoInterstitialCase)
    }
    public func testGamRenderingVideoInterstitialAd() {
        testAd(testCase: testCases.gamVideoInterstitialCase)
    }
    public func testAdMobVideoInterstitialAd() {
        testAd(testCase: testCases.adMobVideoInterstitialCase)
    }
    
    override func checkAd(testCase: String) {
        if testCase == testCases.gamOriginalVideoInterstitialCase {
            XCTAssert(app.webViews.element.waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
            XCTAssert(app.buttons["Close Advertisement"].waitForExistence(timeout: 15),assertFailedMessage(testCase: testCase, reason: "Close Button is not displayed"))
        } else {
            XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
            XCTAssert(app.buttons["Learn More"].waitForExistence(timeout: 10),assertFailedMessage(testCase: testCase, reason: "Learn more button is not displayed"))
            XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 15),assertFailedMessage(testCase: testCase, reason: "Video close button is not displayed"))
        }
    }
}

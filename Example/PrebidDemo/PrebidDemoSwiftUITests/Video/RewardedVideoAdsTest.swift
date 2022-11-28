//
//  RewardedVideoAds.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 28.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import Foundation
import XCTest

//class RewardedVideoAds: BaseAdsTest {
//    
//    public func testInAppVideoRewardedAd() {
//        testAd(testCase: testCases.inAppVideoRewardedCase)
//    }
//    public func testGamOriginalVideoRewardedAd() {
//        testAd(testCase: testCases.gamOriginalVideoRewardedCase)
//    }
//    public func testGamRenderingVideoRewardedAd() {
//        testAd(testCase: testCases.gamVideoRewardedCase)
//    }
//    public func testAdMobVideoRewardedAd() {
//        testAd(testCase: testCases.adMobVideoRewardedCase)
//    }
//    
//    override func checkAd(testCase: String) {
//        if testCase == testCases.gamOriginalVideoRewardedCase {
//            XCTAssert(app.webViews.element.waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
//            XCTAssert(app.buttons["Close Advertisement"].waitForExistence(timeout: 15),assertFailedMessage(testCase: testCase, reason: "Close Button is not displayed"))
//            XCTAssert(app.images.element.waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "End card is not displayed"))
//        } else {
//            XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
//            XCTAssert(app.webViews["PBMInternalWebViewAccessibilityIdentifier"].waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "End card is not displayed"))
//            XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video close button is not displayed"))
//        }
//    }
//}

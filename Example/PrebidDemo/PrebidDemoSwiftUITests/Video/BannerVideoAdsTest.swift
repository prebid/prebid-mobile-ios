//
//  BannerVideoAds.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 28.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import Foundation
import XCTest

class BannerVideoAds: BaseAdsTest {
    
    public func testInAppVideoBannerAd() {
        testAd(testCase: testCases.inAppVideoBannerCase)
    }
    public func testGamOriginalVideoBannerAd() {
        testAd(testCase: testCases.gamOriginalVideoBannerCase)
    }
    public func testGamRenderingVideoBannerAd() {
        testAd(testCase: testCases.gamVideoBannerCase)
    }
    public func testAdMobVideoBannerAd() {
        testAd(testCase: testCases.adMobVideoBannerCase)
    }
    
    override func checkAd(testCase: String) {
        if testCase == testCases.gamOriginalVideoBannerCase {
            XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "Play video button is not displayed"))
        } else {
            XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
        }
    }
    
}

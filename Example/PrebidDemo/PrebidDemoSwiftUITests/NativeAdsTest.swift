//
//  NativeAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 10.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class NativeAdsTest: BaseAdsTest {
    
    public func testInAppNativeAd() {
        testAd(testCase: testCases.inAppNativeCase)
    }
    public func testGamOriginalNativeAd() {
        testAd(testCase: testCases.gamOriginalNativeCase)
    }
    public func testGamRenderingNativeAd() {
        testAd(testCase: testCases.gamNativeCase)
    }
    public func testAdMobNativeAd() {
        testAd(testCase: testCases.adMobNativeCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(app.staticTexts["OpenX (Title)"].waitForExistence(timeout: 10),assertFailedMessage(testCase: testCase, reason: "Open X title is not displayed"))
        
    }
}

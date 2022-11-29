//
//  BannerAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 09.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

@testable import PrebidMobile
@testable import PrebidDemoSwift
class BannerAdsTest: BaseAdsTest {
    
    public func testInAppBannerAd() {
        testAd(testCase: testCases.inAppDisplayBannerCase)
    }
    public func testGamOriginalBannerAd() {
        testAd(testCase: testCases.gamOriginalDisplayBannerCase)
    }
    public func testGamRenderingBannerAd() {
        testAd(testCase: testCases.gamDisplayBannerCase)
    }
    public func testAdMobBannerAd() {
        testAd(testCase: testCases.adMobDisplayBannerCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10), assertFailedMessage(testCase: testCase,reason: "Banner Web View is not displayed"))
    }


}

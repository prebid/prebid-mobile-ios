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
        testAd(adServer: inApp, adName: banner)
    }
    public func testGamOriginalBannerAd() {
        testAd(adServer: gam, adName: banner)
    }
    public func testGamRenderingBannerAd() {
        testAd(adServer: gamR, adName: banner)
    }
    public func testAdMobBannerAd() {
        testAd(adServer: adMobR, adName: banner)
    }
    
    override func checkAd(adServer: String, adName: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10), assertFailedMessage(adServer: adServer,adName: adName,reason: "Banner Web View is not displayed"))
    }


}
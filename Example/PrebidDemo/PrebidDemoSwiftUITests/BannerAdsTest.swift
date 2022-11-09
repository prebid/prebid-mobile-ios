//
//  BannerAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 09.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class BannerAdsTest: BaseAdsTest {
    
    public func testBannerAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: banner)
        testAd(adServer: gam, adName: banner)
        testAd(adServer: gamR, adName: banner)
        testAd(adServer: adMobR, adName: banner)
    }
    
    override func checkAd(adServer: String, adName: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10),"Ad Failed \(adServer) - \(adName)")
    }


}

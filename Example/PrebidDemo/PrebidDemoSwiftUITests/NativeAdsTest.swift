//
//  NativeAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 10.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class NativeAdsTest: BaseAdsTest {
    public func testNativeAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: native)
        testAd(adServer: gam, adName: native)
        testAd(adServer: gamR, adName: native)
        testAd(adServer: adMobR, adName: native)
    }
    
    override func checkAd(adServer: String, adName: String) {
        let element = adServer == adMobR ? app.buttons["OpenX (Title)"] : app.staticTexts["OpenX (Title)"]
        XCTAssert(element.waitForExistence(timeout: 10),assertFailedMessage(adServer: adServer, adName: adName, reason: "Open X title is not displayed"))
        
    }
}

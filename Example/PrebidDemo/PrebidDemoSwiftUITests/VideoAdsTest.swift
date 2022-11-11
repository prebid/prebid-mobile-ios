//
//  VideoAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 11.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class VideoAdsTest: BaseAdsTest {
    
//    public func testVideoBannerAdsShouldBeDisplayed() {
//        testAd(adServer: inApp, adName: bannerVideo)
//        testAd(adServer: gam, adName: bannerVideo)
//        testAd(adServer: gamR, adName: bannerVideo)
//        testAd(adServer: adMobR, adName: bannerVideo)
//    }

    public func testVideoInterstitialAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: interstitialVideo)
        testAd(adServer: gam, adName: interstitialVideo)
        testAd(adServer: gamR, adName: interstitialVideo)
        testAd(adServer: adMobR, adName: interstitialVideo)
    }
//    
    public func testVideoRewardedAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: rewarded)
        testAd(adServer: gam, adName: rewarded)
        testAd(adServer: gamR, adName: rewarded)
        testAd(adServer: adMobR, adName: rewarded)
    }
    
    override func checkAd(adServer: String, adName: String) {

////        switch adName {
////        case bannerVideo:
//        checkBannerVideo(adServer: adServer, adName: adName)
        XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video is not displayed"))
//        default:
//            throw Error
//        }
        
    }
    private func checkBannerVideo(adServer: String, adName: String) {
        XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video is not displayed"))
    }
    

}

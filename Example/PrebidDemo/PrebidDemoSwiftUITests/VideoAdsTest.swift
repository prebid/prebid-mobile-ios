//
//  VideoAdsTest.swift
//  PrebidDemoSwiftUITests
//
//  Created by mac-admin on 11.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest
enum NoAdError: Error {
    case runtimeError(String)
}
class VideoAdsTest: BaseAdsTest {
    
    public func testVideoBannerAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: bannerVideo)
        testAd(adServer: gam, adName: bannerVideo)
        testAd(adServer: gamR, adName: bannerVideo)
        testAd(adServer: adMobR, adName: bannerVideo)
    }

    public func testVideoInterstitialAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: interstitialVideo)
        testAd(adServer: gam, adName: interstitialVideo)
        testAd(adServer: gamR, adName: interstitialVideo)
        testAd(adServer: adMobR, adName: interstitialVideo)
    }

    public func testVideoRewardedAdsShouldBeDisplayed() {
        testAd(adServer: inApp, adName: rewarded)
        testAd(adServer: gam, adName: rewarded)
        testAd(adServer: gamR, adName: rewarded)
        testAd(adServer: adMobR, adName: rewarded)
    }
    
    override func checkAd(adServer: String, adName: String) {
        switch (adName) {
        case bannerVideo:
            if adServer == gam {
                checkGamBannerVideo()
            } else {
                checkVideo(adServer: adServer, adName: adName)
            }
        case interstitialVideo:
            if adServer == gam {
                checkGamInterstitialVideo()
            } else {
                checkVideoInterstital(adServer: adServer, adName: adName)
            }
        case rewarded:
            if adServer == gam {
                checkGamRewardedVideo()
            } else {
                checkRewardedVideo(adServer: adServer, adName: adName)
            }
        default:
            checkVideo(adServer: adServer, adName: adName)
        }
    }
    private func checkVideo(adServer: String, adName: String) {
        XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video is not displayed"))
    }
    private func checkVideoInterstital(adServer: String, adName: String) {
        checkVideo(adServer: adServer, adName: adName)
        XCTAssert(app.buttons["Learn More"].waitForExistence(timeout: 10),assertFailedMessage(adServer: adServer, adName: adName, reason: "Learn more button is not displayed"))
        XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 15),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video close button is not displayed"))
    }
    private func checkRewardedVideo(adServer: String, adName: String) {
        checkVideo(adServer: adServer, adName: adName)
        XCTAssert(app.webViews["PBMInternalWebViewAccessibilityIdentifier"].waitForExistence(timeout: 20),assertFailedMessage(adServer: adServer, adName: adName, reason: "End card is not displayed"))
        XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 15),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video close button is not displayed"))
    }
    
    private func checkGamBannerVideo() {
        XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 30),assertFailedMessage(adServer: gam, adName: bannerVideo, reason: "Play video button is not displayed"))
    }
    
    private func checkGamInterstitialVideo() {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 30),assertFailedMessage(adServer: gam, adName: interstitialVideo, reason: "Video is not displayed"))
        XCTAssert(app.buttons["Close Advertisement"].waitForExistence(timeout: 15),assertFailedMessage(adServer: gam, adName: interstitialVideo, reason: "Close Button is not displayed"))
    }
    private func checkGamRewardedVideo() {
        checkGamInterstitialVideo()
        XCTAssert(app.images.element.waitForExistence(timeout: 20),assertFailedMessage(adServer: gam, adName: interstitialVideo, reason: "End card is not displayed"))
    }
    

}

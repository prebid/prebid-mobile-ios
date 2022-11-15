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
    
    // Video banner
    public func testInAppVideoBannerAd() {
        testAd(adServer: inApp, adName: bannerVideo)
    }
    public func testGamOriginalVideoBannerAd() {
        testAd(adServer: gam, adName: bannerVideo)
    }
    public func testGamRenderingVideoBannerAd() {
        testAd(adServer: gamR, adName: bannerVideo)
    }
    public func testAdMobVideoBannerAd() {
        testAd(adServer: adMobR, adName: bannerVideo)
    }
    

    // Video interstitial
    public func testInAppVideoInterstitialAd() {
        testAd(adServer: inApp, adName: interstitialVideo)
    }
    public func testGamOriginalVideoInterstitialAd() {
        testAd(adServer: gam, adName: interstitialVideo)
    }
    public func testGamRenderingVideoInterstitialAd() {
        testAd(adServer: gamR, adName: interstitialVideo)
    }
    public func testAdMobVideoInterstitialAd() {
        testAd(adServer: adMobR, adName: interstitialVideo)
    }

    // Video rewarded
    public func testInAppVideoRewardedAd() {
        testAd(adServer: inApp, adName: rewarded)
    }
    public func testGamOriginalVideoRewardedAd() {
        testAd(adServer: gam, adName: rewarded)
    }
    public func testGamRenderingVideoRewardedAd() {
        testAd(adServer: gamR, adName: rewarded)
    }
    public func testAdMobVideoRewardedAd() {
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
                checkGamInterstitialVideo(videoName: interstitialVideo)
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
//        XCTAssert(app.webViews["PBMInternalWebViewAccessibilityIdentifier"].waitForExistence(timeout: 30),assertFailedMessage(adServer: adServer, adName: adName, reason: "End card is not displayed"))
        XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 20),assertFailedMessage(adServer: adServer, adName: adName, reason: "Video close button is not displayed"))
    }
    
    private func checkGamBannerVideo() {
        XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 30),assertFailedMessage(adServer: gam, adName: bannerVideo, reason: "Play video button is not displayed"))
    }
    
    private func checkGamInterstitialVideo(videoName: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 30),assertFailedMessage(adServer: gam, adName: videoName, reason: "Video is not displayed"))
        XCTAssert(app.buttons["Close Advertisement"].waitForExistence(timeout: 15),assertFailedMessage(adServer: gam, adName: videoName, reason: "Close Button is not displayed"))
    }
    private func checkGamRewardedVideo() {
        checkGamInterstitialVideo(videoName: rewarded)
//        XCTAssert(app.images.element.waitForExistence(timeout: 20),assertFailedMessage(adServer: gam, adName: rewarded, reason: "End card is not displayed"))
    }
    

}

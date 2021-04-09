//
//  PrebidVideoInterstitialUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class PrebidVideoInterstitialUITest: RepeatedUITestCase {

    private let waitingTimeout = 5.0
    private let videoDuration = TimeInterval(17)

    let videoInterstitialTitle = "Video Interstitial 320x480 (PPM)"
    let videoInterstitialEndCardTitle = "Video Interstitial 320x480 with End Card (PPM)"
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testVideoInterstitial() {
        repeatTesting(times: 7) {
            
            openVideo(title: videoInterstitialTitle)
            
            // Wait for the Learn more.
            let LearnMoreBtn = app.buttons["Learn More"]
            waitForExists(element: LearnMoreBtn, waitSeconds: 5 )
            
            // Wait for Close
            let interstitialCloseBtn = app.buttons["OXMCloseButton"]
            waitForHittable(element: interstitialCloseBtn, waitSeconds: 5)
            interstitialCloseBtn.tap()
            
            verifyPostEvents(expectClick: false)
        }
    }
    
    func testLearnMore() {
        repeatTesting(times: 7) {
            openVideo(title: videoInterstitialTitle)
            
            // Wait for the Learn more.
            let LearnMoreBtn = app.buttons["Learn More"]
            waitForExists(element: LearnMoreBtn, waitSeconds: 5 )
            
            LearnMoreBtn.tap()
            
            // Wait for the click through browser to come up.
            let clickthroughBrowserCloseBtn = app.buttons["OXMCloseButtonClickThroughBrowser"]
            waitForHittable(element: clickthroughBrowserCloseBtn, waitSeconds: 5)
            clickthroughBrowserCloseBtn.tap()
            
            let videoCloseBtn = app.buttons["OXMCloseButton"]
            waitForHittable(element: videoCloseBtn, waitSeconds: 5)
            videoCloseBtn.tap()
            
            verifyPostEvents(expectClick: true)
        }
    }
    
    func testAutoClose() {
        repeatTesting(times: 7) {
            openVideo(title: videoInterstitialTitle)
            
            let videoCloseBtn = app.buttons["OXMCloseButton"]
            waitForHittable(element: videoCloseBtn, waitSeconds: 5)
            
            // The close button should disappear
            // It means the video has closed automatically
            waitForNotExist(element: videoCloseBtn, waitSeconds: 20)
            
            verifyPostEvents(expectClick: false)
        }
    }
    
    func testTapEndCardThenClose() {
        repeatTesting(times: 7) {
            openVideo(title: videoInterstitialEndCardTitle)
            
            // Waiting for the end of the video...
            Thread.sleep(forTimeInterval: videoDuration)
            
            // Tap on End card
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: 2)
            endCardLink.tap()
            
            // Close button should be present
            let videoCloseBtn = app.buttons["OXMCloseButtonClickThroughBrowser"]
            waitForHittable(element: videoCloseBtn, waitSeconds: 5)
            videoCloseBtn.tap()
            
            verifyPostEvents(expectClick: true)
        }
    }

    // MARK: - Private methods
    private func openVideo(title: String) {
        navigateToExamplesSection()
        navigateToExample(title)
        
        waitAd()
        
        let showButton = app.buttons["Show"]
        waitForEnabled(element: showButton)
        showButton.tap()
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["interstitialDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["interstitialDidFailToReceiveAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func verifyPostEvents(expectClick: Bool) {
        XCTAssertTrue(app.buttons["interstitialWillPresentAd called"].isEnabled)
        XCTAssertTrue(app.buttons["interstitialDidDismissAd called"].isEnabled)
        XCTAssertFalse(app.buttons["interstitialWillLeaveApplication called"].isEnabled)
        XCTAssertEqual(app.buttons["interstitialDidClickAd called"].isEnabled, expectClick)
    }
}

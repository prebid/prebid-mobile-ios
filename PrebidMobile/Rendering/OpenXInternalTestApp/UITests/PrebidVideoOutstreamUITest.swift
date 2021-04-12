//
//  PrebidVideoOutstreamUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class PrebidVideoOutstreamUITest: RepeatedUITestCase {

    private let waitingTimeout = 30.0
    private let videoDuration = TimeInterval(17) + 2

    let videoOutstreamTitle = "Video Outstream (PPM)"
    let videoOutstreamEndCardTitle = "Video Outstream with End Card (PPM)"
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testVideoAdViewStatic() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamTitle)
            
            let watchAgainButton = app.buttons["Watch Again"]
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: false)
            
            watchAgainButton.tap()
            
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: false)
        }
    }
    
    func testVideoAdViewTapAndClose() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamTitle)
            
            let bannerView = app.descendants(matching: .other)["OXABannerView"]
            bannerView.tap()

            // Wait for the click through browser to come up.
            let clickthroughBrowserCloseBtn = app.buttons["OXMCloseButtonClickThroughBrowser"]
            waitForHittable(element: clickthroughBrowserCloseBtn, waitSeconds: 5)
            clickthroughBrowserCloseBtn.tap()

            let watchAgainButton = app.buttons["Watch Again"]
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: true)
        }
    }
    
    func testVideoAdViewStaticTapEndCard() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamEndCardTitle)
            
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: videoDuration)
            endCardLink.tap()

            let videoCloseBtn = app.buttons["OXMCloseButtonClickThroughBrowser"]
            
            waitForExists(element: videoCloseBtn, waitSeconds: 10)
            videoCloseBtn.tap()
            
            verifyPostEvents(screenWasPresented: true)
        }
    }
    
    // MARK: - Private methods
    private func openVideo(title: String) {
        navigateToExamplesSection()
        navigateToExample(title)
        
        waitAd()
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func verifyPostEvents(screenWasPresented: Bool) {
        XCTAssertEqual(app.buttons["adViewWillPresentScreen called"].isEnabled, screenWasPresented)
        XCTAssertEqual(app.buttons["adViewDidDismissScreen called"].isEnabled, screenWasPresented)
        XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
    }

}

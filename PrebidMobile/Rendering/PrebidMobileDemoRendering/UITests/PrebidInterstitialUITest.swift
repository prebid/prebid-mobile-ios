//
//  PrebidHTMLInterstitialUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class PrebidInterstitialUITest: RepeatedUITestCase {

    private let waitingTimeout = 5.0
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testPresentationShow() {
        repeatTesting(times: 3) {
            navigateToExamplesSection()
            navigateToExample("Display Interstitial 320x480 (PPM) [Presentation]")
        
            let adReceivedButton = app.buttons["interstitialDidReceiveAd called"]
            
            waitForEnabled(element: adReceivedButton, failElement: nil, waitSeconds: waitingTimeout)
            
            let showButton = app.buttons["Show"]
            waitForEnabled(element: showButton)
        }
    }
    
    func testShow() {
        repeatTesting(times: 3) {
            navigateToExamplesSection()
            navigateToExample("Display Interstitial 320x480 (PPM)")
        
            let adReceivedButton = app.buttons["interstitialDidReceiveAd called"]
            
            waitForEnabled(element: adReceivedButton, failElement: nil, waitSeconds: waitingTimeout)
            
            //Wait and press the Show button
            let showButton = app.buttons["Show"]
            waitForEnabled(element: showButton)
            showButton.tap()
            
            //Wait for the custom close button to appear, then tap it.
            let interstitialCloseBtn = app.buttons["OXMCloseButton"]
            waitForHittable(element: interstitialCloseBtn, waitSeconds: 4)
            interstitialCloseBtn.tap()
            
            // Verify event labels
            XCTAssertTrue(app.buttons["interstitialWillPresentAd called"].isEnabled)
            XCTAssertTrue(app.buttons["interstitialDidDismissAd called"].isEnabled)
            XCTAssertFalse(app.buttons["interstitialWillLeaveApplication called"].isEnabled)
            XCTAssertFalse(app.buttons["interstitialDidClickAd called"].isEnabled)
        }
    }

}

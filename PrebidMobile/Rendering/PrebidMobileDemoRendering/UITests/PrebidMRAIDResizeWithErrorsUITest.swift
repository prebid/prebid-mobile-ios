//
//  PrebidMRAIDResizeWithErrorsUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class PrebidMRAIDResizeWithErrorsUITest: RepeatedUITestCase {
    
    private let title = "MRAID 2.0: Resize with Errors (PPM)"
    private let waitingTimeout = 10.0
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testBasic() {
        repeatTesting(times: 7) {
            
            openAndWaitAd()
            
            let mraidView =  app.buttons["PBMAdView"]
            waitForExists(element: mraidView, waitSeconds: waitingTimeout)
            
            let propertiesTextLabel = mraidView.staticTexts["Test properties:"]
            waitForExists(element: propertiesTextLabel, waitSeconds: waitingTimeout)

            let offScreenTextLabel = mraidView.staticTexts["Test offScreen:"]
            waitForExists(element: offScreenTextLabel, waitSeconds: waitingTimeout)
        }
    }
    
    func testResize() {
        repeatTesting(times: 7) {
        
            openAndWaitAd()
            
            let mraidView =  app.buttons["PBMAdView"]
            waitForExists(element: mraidView, waitSeconds: waitingTimeout)
            
            var offScreenButton = mraidView.staticTexts["TRUE"]
            waitForExists(element: offScreenButton, waitSeconds: waitingTimeout)
            offScreenButton.tap()
            
            Thread.sleep(forTimeInterval: 1)
            
            offScreenButton = mraidView.staticTexts["FALSE"]
            waitForExists(element: offScreenButton, waitSeconds: waitingTimeout)

            let arrowButton = mraidView.staticTexts["→"]
            waitForExists(element: arrowButton, waitSeconds: waitingTimeout)
            arrowButton.tap()

            Thread.sleep(forTimeInterval: 1)

            let closeBtn = app.buttons["PBMCloseButton"]
            waitForHittable(element: closeBtn, waitSeconds: waitingTimeout)
            closeBtn.tap()
        }
    }
    
    // MARK: - Private methods
    private func openAndWaitAd() {
        navigateToExamplesSection()
        navigateToExample(title)
        
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
}

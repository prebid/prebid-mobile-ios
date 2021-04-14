//
//  PrebidBannerUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit

class PrebidBannerUITest: RepeatedUITestCase {
    
    private let waitingTimeout = 10.0
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }

    func testMultiClick() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (PPM)")
            
            let bannerView = app.descendants(matching: .other)["OXABannerView"]
            
            waitAd()
            
            XCTAssertEqual(bannerView.children(matching: .any).count, 1)
            
            Thread.sleep(forTimeInterval: 1)
            bannerView.tap(withNumberOfTaps: 10, numberOfTouches: 1)
            
            // Wait for the close button, then press it.
            let interstitialCloseBtn = app.buttons["OXMCloseButtonClickThroughBrowser"]
            waitForExists(element: interstitialCloseBtn, waitSeconds: 12)
            interstitialCloseBtn.tap()

            waitForExists(element: bannerView, waitSeconds: waitingTimeout)
            
            // Verify event labels
            XCTAssertTrue(app.buttons["adViewWillPresentScreen called"].isEnabled)
            XCTAssertTrue(app.buttons["adViewDidDismissScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
        }
    }
    
    func testOpenInNewTab() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (PPM) [New Tab]")
            
            waitAd()
            
            for linkText in ["default", "_blank",  "_self", "onclick_self", "onclick_blank"] {
                
                let link = app.staticTexts[linkText]
                link.tap()
                
                let closeButton = app.buttons["OXMCloseButtonClickThroughBrowser"]
                waitForExists(element: closeButton, waitSeconds: waitingTimeout)
                closeButton.tap()
            }
        }
    }
    
    func testIncorrectVastData() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (PPM) [Incorrect VAST]")
            
            // Wait for the ad to load.
            waitForEnabled(element: app.buttons["adViewDidFailToLoadAd called"], waitSeconds: 5)
            
            // Verify event labels are NOT enabled
            XCTAssertFalse(app.buttons["adViewDidReceiveAd called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillPresentScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewDidDismissScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
        }
    }
    
    /*
     This test case deals with the MoPub ad unit 2b664935d41c4f4f8b8148ae39d22c99
     which shows either normal banner (when the prebid server returns a bid)
     or just an HTML-banner with the text "No Bids Banner"
     It runs with the 'random no bids' mock-server mode:
     https://github.com/openx/mobile-mock-server#set-random-no-bids
     */
    func testRandomNoBidsMoPub() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (MoPub) [Random, Respective]")

            
            let reloadButton = app.buttons["[Reload]"]
            var isAdLoaded = false
            var isNoBidsBannerLoaded = false
            
            for _ in 0...7 {
                waitMoPubAd()
            
                let views = app.descendants(matching: .webView)
                viewsLoop: for view in views.allElementsBoundByAccessibilityElement {
                    if view.identifier == "OXMInternalWebViewAccessibilityIdentifier" {
                        isAdLoaded = true
                        break
                    }
                    let staticTexts = view.descendants(matching: .staticText)
                    for text in staticTexts.allElementsBoundByIndex {
                        if text.label == "No Bids Banner" {
                            isNoBidsBannerLoaded = true
                            break viewsLoop;
                        }
                    }
                }
                
                //we have got both cases
                if isAdLoaded && isNoBidsBannerLoaded {
                    break
                }
                
                reloadButton.tap()
            }
            
            //Move back to call MockServer's /api/cancel_random_no_bids
            let backButton = app.buttons["Back"]
            backButton.tap()
            
            XCTAssertTrue(isAdLoaded)
            XCTAssertTrue(isNoBidsBannerLoaded)
        }
    }
    
    func testRandomNoBidsGAM() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (GAM) [Random, Respective]")

            
            let reloadButton = app.buttons["[Reload]"]
            var isAdLoaded = false
            var isAdNotLoaded = false
            
            for _ in 0...4 {
                waitForEnabled(element: reloadButton, failElement: nil, waitSeconds: waitingTimeout)
                
                //a response with a bid
                if app.buttons["adViewDidReceiveAd called"].isEnabled {
                    isAdLoaded = true
                }
                
                //a response with without a bid
                if app.buttons["adViewDidFailToLoadAd called"].isEnabled {
                    isAdNotLoaded = true
                }
                
                //we have got both cases
                if isAdLoaded && isAdNotLoaded {
                    break
                }

                reloadButton.tap()
            }
            
            //Move back to call MockServer's /api/cancel_random_no_bids
            let backButton = app.buttons["Back"]
            backButton.tap()
            
            XCTAssertTrue(isAdLoaded)
            XCTAssertTrue(isAdNotLoaded)
        }
    }
    
    func testPPMBannerNativeStyle_NoCreative() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner Native Styles No Creative (PPM)")
            
            // Wait for the ad to load.
            waitForEnabled(element: app.buttons["adViewDidFailToLoadAd called"], waitSeconds: 5)
            
            // Verify event labels are NOT enabled
            XCTAssertFalse(app.buttons["adViewDidReceiveAd called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillPresentScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewDidDismissScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
        }
    }
    
    // MARK: - Private methods
    private func waitAd() {
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func waitMoPubAd() {
        let adReceivedButton = app.buttons["adViewDidLoadAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFail called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }

}

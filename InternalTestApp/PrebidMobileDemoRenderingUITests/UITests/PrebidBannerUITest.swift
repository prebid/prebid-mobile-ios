/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
            navigateToExample("Banner 320x50 (In-App)")
            
            let bannerView = app.descendants(matching: .other)["PrebidBannerView"]
            
            waitAd()
            
            XCTAssertEqual(bannerView.children(matching: .any).count, 1)
            
            Thread.sleep(forTimeInterval: 1)
            bannerView.tap(withNumberOfTaps: 10, numberOfTouches: 1)
            
            // Wait for the close button, then press it.
            let interstitialCloseBtn = app.buttons["PBMCloseButtonClickThroughBrowser"]
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
            navigateToExample("Banner 320x50 (In-App) [New Tab]")
            
            waitAd()
            
            for linkText in ["default", "_blank",  "_self", "onclick_self", "onclick_blank"] {
                
                let link = app.staticTexts[linkText]
                link.tap()
                
                let closeButton = app.buttons["PBMCloseButtonClickThroughBrowser"]
                waitForExists(element: closeButton, waitSeconds: waitingTimeout)
                closeButton.tap()
            }
        }
    }
    
    func testIncorrectVastData() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (In-App) [Incorrect VAST]")
            
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
                    if view.identifier == "PBMInternalWebViewAccessibilityIdentifier" {
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
    
    func testNoRefreshInBackground() {
        repeatTesting(times: 7) {
            
            let settingsItem = app.buttons["⚙"]
            settingsItem.tap()
            
            let tablesQuery = app.tables
            let listItem = tablesQuery.staticTexts["Banner 320x50 (In-App)"]
            waitForExists(element: listItem, waitSeconds: 5)
            listItem.tap()
            
            Thread.sleep(forTimeInterval: 1)
            
            let autoRefreshDelayField = tablesQuery.textFields["refreshInterval_field"]
            waitForExists(element: autoRefreshDelayField, waitSeconds: 5)
            autoRefreshDelayField.tap()
            autoRefreshDelayField.typeText("1")
            
            let loadButton = tablesQuery.buttons["load_ad"]
            XCTAssert(loadButton.isEnabled)
            loadButton.tap()
            
            Thread.sleep(forTimeInterval: 3)

            let labelTotal = self.app.staticTexts["adViewDidReceiveAd called times total"].firstMatch
            XCTAssertEqual(labelTotal.label, "1")
            
            let expectation = expectation(description: "total count")
            XCUIDevice.shared.press(XCUIDevice.Button.home)

            DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
                self.app.activate()
                
                // We wait 3 refresh cycles and want to see only to ad requests
                let labelTotal = self.app.staticTexts.element(matching:.any, identifier:"adViewDidReceiveAd called times total")
                XCTAssertEqual(labelTotal.label, "1")
                expectation.fulfill()
            }
                 
            waitForExpectations(timeout: 45)
        }
    }
    
    func testNoRefreshInNewTab() {
        repeatTesting(times: 7) {
            
            let settingsItem = app.buttons["⚙"]
            settingsItem.tap()
            
            let tablesQuery = app.tables
            let listItem = tablesQuery.staticTexts["Banner 320x50 (In-App)"]
            waitForExists(element: listItem, waitSeconds: 5)
            listItem.tap()
            
            Thread.sleep(forTimeInterval: 1)
            
            let autoRefreshDelayField = tablesQuery.textFields["refreshInterval_field"]
            waitForExists(element: autoRefreshDelayField, waitSeconds: 5)
            autoRefreshDelayField.tap()
            autoRefreshDelayField.typeText("1")
            
            let loadButton = tablesQuery.buttons["load_ad"]
            XCTAssert(loadButton.isEnabled)
            loadButton.tap()
            
            Thread.sleep(forTimeInterval: 2)

            let labelTotal = self.app.staticTexts["adViewDidReceiveAd called times total"].firstMatch
            XCTAssertEqual(labelTotal.label, "1")
            
            let expectation = expectation(description: "total count")
            
            app.tabBars.buttons.element(boundBy: 1).tap()

            DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
                self.app.tabBars.buttons.element(boundBy: 0).tap()
                
                Thread.sleep(forTimeInterval: 2)

                
                // We wait 3 refresh cycles and want to see only to ad requests
                let labelTotal = self.app.staticTexts.element(matching:.any, identifier:"adViewDidReceiveAd called times total")
                XCTAssertEqual(labelTotal.label, "1")
                expectation.fulfill()
            }
                 
            waitForExpectations(timeout: 45)
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

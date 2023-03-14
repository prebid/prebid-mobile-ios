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
            
            let done = app.descendants(matching: .button)["Done"]
            waitForExists(element: done, waitSeconds: waitingTimeout)
            done.tapFrameCenter()
            
            waitForExists(element: bannerView, waitSeconds: waitingTimeout)
            
            XCTAssertTrue(app.buttons["adViewWillPresentScreen called"].isEnabled)
            XCTAssertTrue(app.buttons["adViewDidDismissScreen called"].isEnabled)
            XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
        }
    }
    
    // FIXME: this test doesn't work properly because of PBS on AWS setup
    func testOpenInNewTab() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (In-App) [New Tab]")
            
            waitAd()
            
            for linkText in ["default", "_blank",  "_self", "onclick_self", "onclick_blank"] {
                
                let link = app.staticTexts[linkText]
                link.tap()
                
                let done = app.descendants(matching: .button)["Done"]
                waitForExists(element: done, waitSeconds: waitingTimeout)
                done.tapFrameCenter()
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
    
    func testRandomNoBidsGAM() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Banner 320x50 (GAM) [Random, Respective]")

            
            let reloadButton = app.buttons["[Reload]"]
            var isAdLoaded = false
            
            for _ in 0...4 {
                waitForEnabled(element: reloadButton, failElement: nil, waitSeconds: waitingTimeout)
                
                //a response with a bid
                if app.buttons["adViewDidReceiveAd called"].isEnabled {
                    isAdLoaded = true
                }
                
                
                //we have got both cases
                if isAdLoaded {
                    break
                }

                reloadButton.tap()
            }
            
            let backButton = app.buttons["Back"]
            backButton.tap()
            
            XCTAssertTrue(isAdLoaded)
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
            
            Thread.sleep(forTimeInterval: 5)

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
    
    private func tapCoordinate(at xCoordinate: Double, and yCoordinate: Double) {
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: xCoordinate, dy: yCoordinate))
        coordinate.tap()
    }
}

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

import XCTest

class PrebidMRAID3UITest: RepeatedUITestCase {

    private let viewabilityComplianceTitle = "MRAID 3.0: Viewability Compliance (In-App)"
    private let loadAndEventsTitle = "MRAID 3.0: Load And Events (In-App)"
    private let resizeNegativeTestTitle = "MRAID 3.0: Resize Negative Test (In-App)"
    private let waitingTimeout = 10.0
    private let timeout = 7.0
    
    private let labels = ["Tap For Expand/sizeChange Check",
                          "Tap To Close Expand",
                          "Tap To Check Logs",
                          "Tap To Unload"
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    func testViewabilityCompliance() {
        repeatTesting(times: 7) {
        
            openAndWaitAd(title: viewabilityComplianceTitle)
            
            var isExposureErrorFound = false
            var isMRAIDEnvErrorFound = false
            
            let testWebView = app.webViews["PBMInternalWebViewAccessibilityIdentifier"]
            let allStaticTexts = testWebView.staticTexts.allElementsBoundByIndex
            
            // There are two possible errors
            for staticText in allStaticTexts {
                if staticText.label.range(of: "exposureChange event is not compliant with IAB specification") != nil {
                    isExposureErrorFound = true
                }
                if staticText.label.range(of: "Environment is not MRAIDV3 Compatible") != nil {
                    isMRAIDEnvErrorFound = true
                }
            }
            
            XCTAssertFalse(isExposureErrorFound, "An Exposure error is found")
            XCTAssertFalse(isMRAIDEnvErrorFound, "An MRAID_ENV error is found")
        }
    }
    
    func testLoadAndEvents() {
        repeatTesting(times: 7) {
        
            openAndWaitAd(title: loadAndEventsTitle)
            
            var link = app.staticTexts["Tap For Expand/stateChange Check"]
            waitForHittable(element: link, waitSeconds: timeout)
            link.tap()
            
            waitForExists(element: app.staticTexts["Tap SDK Close Button"], waitSeconds: timeout)
            
            let browserCloseButton = app.buttons["PBMCloseButton"]
            waitForHittable(element: browserCloseButton, waitSeconds: timeout)
            browserCloseButton.tap()
            
            var shouldCheckCloseButton = true
            for label in labels {
                link = app.staticTexts[label]
                waitForHittable(element: link, waitSeconds: timeout)
                link.tap()
                
                if shouldCheckCloseButton {
                    waitForHittable(element: browserCloseButton, waitSeconds: timeout)
                }
                
                shouldCheckCloseButton = !shouldCheckCloseButton
            }
        }
    }
    
    func testResizeNegativeTests() {
        repeatTesting(times: 7) {
        
            openAndWaitAd(title: resizeNegativeTestTitle)
            
            Thread.sleep(forTimeInterval: 8)
            let testWebView = app.webViews["PBMInternalWebViewAccessibilityIdentifier"]
            
            var passedTestsCount = 0;
            
            let allStaticTexts = testWebView.staticTexts.allElementsBoundByIndex
            for staticText in allStaticTexts {
                if staticText.label.range(of:"PASSED:") != nil {
                    passedTestsCount+=1
                }
            }
            XCTAssertEqual(passedTestsCount, 13)
        }
    }
    
    // MARK: - Private methods
    private func openAndWaitAd(title: String) {
        navigateToExamplesSection()
        navigateToExample(title)
        
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }

}

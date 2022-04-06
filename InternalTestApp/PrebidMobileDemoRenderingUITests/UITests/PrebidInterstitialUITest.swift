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

class PrebidInterstitialUITest: RepeatedUITestCase {

    private let waitingTimeout = 5.0
    
    override func setUp() {
        super.setUp()
    }
    
    func testPresentationShow() {
        repeatTesting(times: 3) {
            navigateToExamplesSection()
            navigateToExample("Display Interstitial 320x480 (In-App) [Presentation]")
        
            let adReceivedButton = app.buttons["interstitialDidReceiveAd called"]
            
            waitForEnabled(element: adReceivedButton, failElement: nil, waitSeconds: waitingTimeout)
            
            let showButton = app.buttons["Show"]
            waitForEnabled(element: showButton)
        }
    }
    
    func testShow() {
        repeatTesting(times: 3) {
            navigateToExamplesSection()
            navigateToExample("Display Interstitial 320x480 (In-App)")
        
            let adReceivedButton = app.buttons["interstitialDidReceiveAd called"]
            
            waitForEnabled(element: adReceivedButton, failElement: nil, waitSeconds: waitingTimeout)
            
            //Wait and press the Show button
            let showButton = app.buttons["Show"]
            waitForEnabled(element: showButton)
            showButton.tap()
            
            //Wait for the custom close button to appear, then tap it.
            let interstitialCloseBtn = app.buttons["PBMCloseButton"]
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

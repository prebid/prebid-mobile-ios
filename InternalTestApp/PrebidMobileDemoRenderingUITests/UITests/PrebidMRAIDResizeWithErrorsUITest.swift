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

class PrebidMRAIDResizeWithErrorsUITest: RepeatedUITestCase {
    
    private let title = "MRAID 2.0: Resize with Errors (In-App)"
    private let waitingTimeout = 10.0
    
    override func setUp() {
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

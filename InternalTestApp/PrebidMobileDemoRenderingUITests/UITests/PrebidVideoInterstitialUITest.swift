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

class PrebidVideoInterstitialUITest: RepeatedUITestCase {

    private let waitingTimeout = 15.0
    private let videoDuration = TimeInterval(17)

    let videoInterstitialTitle = "Video Interstitial 320x480 (In-App)"
    let videoInterstitialEndCardTitle = "Video Interstitial 320x480 with End Card (In-App)"
    
    override func setUp() {
        super.setUp()
    }
    
    func testVideoInterstitial() {
        repeatTesting(times: 7) {
            
            openVideo(title: videoInterstitialTitle)
            
            // Wait for the Learn more.
            let LearnMoreBtn = app.buttons["Learn More"]
            waitForExists(element: LearnMoreBtn, waitSeconds: 5 )
            
            // Wait for Close
            let interstitialCloseBtn = app.buttons["PBMCloseButton"]
            waitForHittable(element: interstitialCloseBtn, waitSeconds: 15)
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
            let done = app.descendants(matching: .button)["Done"]
            waitForExists(element: done, waitSeconds: waitingTimeout)
            done.tapFrameCenter()
            
            let videoCloseBtn = app.buttons["PBMCloseButton"]
            waitForHittable(element: videoCloseBtn, waitSeconds: 15)
            videoCloseBtn.tap()
            
            verifyPostEvents(expectClick: true)
        }
    }
    
    func testAutoClose() {
        repeatTesting(times: 7) {
            openVideo(title: videoInterstitialTitle)
            
            let videoCloseBtn = app.buttons["PBMCloseButton"]
            waitForHittable(element: videoCloseBtn, waitSeconds: 15)
            
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
            let done = app.descendants(matching: .button)["Done"]
            waitForExists(element: done, waitSeconds: waitingTimeout)
            done.tapFrameCenter()
            
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

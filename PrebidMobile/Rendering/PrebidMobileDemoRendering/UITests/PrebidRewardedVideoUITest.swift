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

class PrebidRewardedVideoUITest: RepeatedUITestCase {
    
    private let waitingTimeout = 5.0
    private let videoDuration = TimeInterval(17)
    
    let videoRewardedTitle = "Video Rewarded 320x480 without End Card (In-App)"
    let videoRewardedEndCardTitle = "Video Rewarded 320x480 (In-App)"
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testTapEndCardThenClose() {
        repeatTesting(times: 7) {
            openVideoAndWait(title: videoRewardedEndCardTitle)
            
            // Tap on End card
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: 2)
            endCardLink.tap()
            
            //The video should still be visible. Close it.
            closeAndVerifyPostEvents(expectClick: true)
        }
    }
    
    func testNoClickthrough () {
        repeatTesting(times: 7) {
            openVideoAndWait(title: videoRewardedEndCardTitle)
            
            closeAndVerifyPostEvents(expectClick: false)
        }
    }
    
    func testAutoClose() {
        repeatTesting(times: 7) {
            openVideoAndWait(title: videoRewardedTitle)
            
            verifyPostEvents(expectClick: false)
        }
    }
    
    // MARK: - Private methods
    private func openVideoAndWait(title: String) {
        navigateToExamplesSection()
        navigateToExample(title)
        
        waitAd()
        
        let showButton = app.buttons["Show"]
        waitForEnabled(element: showButton)
        showButton.tap()
        
        // 17 second video
        let circularProgress = app.buttons["CircularProgressView"]
        waitForHittable(element: circularProgress, waitSeconds: videoDuration)
        waitForExists(element: circularProgress, waitSeconds: videoDuration)
        
        // Wait for the circular progress to go away
        // It means the video has closed automatically
        waitForNotExist(element: circularProgress, waitSeconds: videoDuration + 3)
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["rewardedAdDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["rewardedAdDidFailToReceiveAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    func closeAndVerifyPostEvents(expectClick: Bool) {
        
        let closeBtn = app.buttons[expectClick ? "PBMCloseButtonClickThroughBrowser" : "PBMCloseButton"]
        waitForExists(element: closeBtn, waitSeconds: 5)
        closeBtn.tap()
        
        verifyPostEvents(expectClick: expectClick)
    }
    
    private func verifyPostEvents(expectClick: Bool) {
        XCTAssertTrue(app.buttons["rewardedAdWillPresentAd called"].isEnabled)
        XCTAssertTrue(app.buttons["rewardedAdDidDismissAd called"].isEnabled)
        XCTAssertFalse(app.buttons["rewardedAdWillLeaveApplication called"].isEnabled)
        XCTAssertEqual(app.buttons["rewardedAdDidClickAd called"].isEnabled, expectClick)
        XCTAssertTrue(app.buttons["rewardedAdUserDidEarnReward called"].isEnabled)
    }

}

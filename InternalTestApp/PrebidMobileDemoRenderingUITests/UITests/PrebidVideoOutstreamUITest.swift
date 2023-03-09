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

class PrebidVideoOutstreamUITest: RepeatedUITestCase {

    private let waitingTimeout = 30.0
    private let videoDuration = TimeInterval(17) + 2

    let videoOutstreamTitle = "Video Outstream (In-App)"
    let videoOutstreamEndCardTitle = "Video Outstream with End Card (In-App)"
    
    override func setUp() {
        super.setUp()
    }
    
    func testVideoAdViewStatic() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamTitle)
            
            let watchAgainButton = app.buttons["Watch Again"]
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: false)
            
            watchAgainButton.tap()
            
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: false)
        }
    }
    
    func testVideoAdViewTapAndClose() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamTitle)
            
            let bannerView = app.descendants(matching: .other)["PrebidBannerView"]
            bannerView.tap()

            // Wait for the click through browser to come up.
            let done = app.descendants(matching: .button)["Done"]
            waitForExists(element: done, waitSeconds: 5)
            done.tapFrameCenter()

            let watchAgainButton = app.buttons["Watch Again"]
            waitForEnabled(element: watchAgainButton, waitSeconds: videoDuration)
            
            verifyPostEvents(screenWasPresented: true)
        }
    }
    
    func testVideoAdViewStaticTapEndCard() {
        repeatTesting(times: 7) {
            openVideo(title: videoOutstreamEndCardTitle)
            
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: videoDuration)
            endCardLink.tap()

            let done = app.descendants(matching: .button)["Done"]
            waitForExists(element: done, waitSeconds: waitingTimeout)
            done.tapFrameCenter()
            
            verifyPostEvents(screenWasPresented: true)
        }
    }
    
    // MARK: - Private methods
    private func openVideo(title: String) {
        navigateToExamplesSection()
        navigateToExample(title)
        
        waitAd()
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func verifyPostEvents(screenWasPresented: Bool) {
        XCTAssertEqual(app.buttons["adViewWillPresentScreen called"].isEnabled, screenWasPresented)
        XCTAssertEqual(app.buttons["adViewDidDismissScreen called"].isEnabled, screenWasPresented)
        XCTAssertFalse(app.buttons["adViewWillLeaveApplication called"].isEnabled)
    }

}

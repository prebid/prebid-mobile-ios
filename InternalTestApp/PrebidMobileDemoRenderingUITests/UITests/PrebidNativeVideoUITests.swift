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

class PrebidNativeVideoUITest: RepeatedUITestCase {
    
    private let waitingTimeout = 10.0
    private let videoDuration = TimeInterval(17) + 2
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testMediaPlaybackEvents() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Native Ad - Video with End Card (In-App)")
            
            waitAd()
            
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: videoDuration)
            
            XCTAssertTrue(app.buttons["onMediaLoadingFinishedButton called"].isEnabled)
            XCTAssertTrue(app.buttons["onMediaPlaybackStartedButton called"].isEnabled)
            XCTAssertTrue(app.buttons["onMediaPlaybackFinishedButton called"].isEnabled)
        }
    }
    
    // MARK: - Private methods
    private func waitAd() {
        let adReceivedButton = app.buttons["getNativeAd success"]
        let adFailedToLoadButton = app.buttons["getNativeAd failed"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
}

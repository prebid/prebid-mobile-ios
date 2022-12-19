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

import Foundation
import XCTest

//class RewardedVideoAds: BaseAdsTest {
//    
//    public func testInAppVideoRewardedAd() {
//        testAd(testCase: testCases.inAppVideoRewardedCase)
//    }
//    public func testGamOriginalVideoRewardedAd() {
//        testAd(testCase: testCases.gamOriginalVideoRewardedCase)
//    }
//    public func testGamRenderingVideoRewardedAd() {
//        testAd(testCase: testCases.gamVideoRewardedCase)
//    }
//    public func testAdMobVideoRewardedAd() {
//        testAd(testCase: testCases.adMobVideoRewardedCase)
//    }
//    
//    override func checkAd(testCase: String) {
//        if testCase == testCases.gamOriginalVideoRewardedCase {
//            XCTAssert(app.webViews.element.waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
//            XCTAssert(app.buttons["Close Advertisement"].waitForExistence(timeout: 15),assertFailedMessage(testCase: testCase, reason: "Close Button is not displayed"))
//            XCTAssert(app.images.element.waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "End card is not displayed"))
//        } else {
//            XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
//            XCTAssert(app.webViews["PBMInternalWebViewAccessibilityIdentifier"].waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "End card is not displayed"))
//            XCTAssert(app.buttons["PBMCloseButton"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video close button is not displayed"))
//        }
//    }
//}

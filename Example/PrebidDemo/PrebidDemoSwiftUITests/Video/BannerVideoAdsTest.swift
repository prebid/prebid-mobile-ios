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

class BannerVideoAds: BaseAdsTest {
    
    public func testInAppVideoBannerAd() {
        testAd(testCase: testCases.inAppVideoBannerCase)
    }
    
    public func testGamOriginalVideoBannerAd() {
        testAd(testCase: testCases.gamOriginalVideoBannerCase)
    }
    
    public func testGamRenderingVideoBannerAd() {
        testAd(testCase: testCases.gamVideoBannerCase)
    }
    
    public func testAdMobVideoBannerAd() {
        testAd(testCase: testCases.adMobVideoBannerCase)
    }
    
    override func checkAd(testCase: String) {
        if testCase == testCases.gamOriginalVideoBannerCase {
            XCTAssert(app.buttons["Learn more"].waitForExistence(timeout: 30),assertFailedMessage(testCase: testCase, reason: "Play learn more is not displayed"))
        } else {
            XCTAssert(app.otherElements["PBMVideoView"].waitForExistence(timeout: 20),assertFailedMessage(testCase: testCase, reason: "Video is not displayed"))
        }
    }
    
}

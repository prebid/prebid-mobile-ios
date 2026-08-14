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

class InterstitialVideoAds: BaseAdsTest {
    
    public func testInAppVideoInterstitialAd() {
        testAd(testCase: testCases.inAppVideoInterstitialCase)
    }
    
    //    public func testGamOriginalVideoInterstitialAd() {
    //        testAd(testCase: testCases.gamOriginalVideoInterstitialCase)
    //    }
    
    public func testGamRenderingVideoInterstitialAd() {
        testAd(testCase: testCases.gamVideoInterstitialCase)
    }
    
    public func testAdMobVideoInterstitialAd() {
        testAd(testCase: testCases.adMobVideoInterstitialCase)
    }
    
    override func checkAd(testCase: String) {
        if testCase == testCases.gamOriginalVideoInterstitialCase {
            assertElementExists(app.webViews.element, testCase: testCase, reason: "Video is not displayed")
            assertElementExists(app.buttons["Close Advertisement"], testCase: testCase, reason: "Close button is not displayed")
        } else {
            assertElementExists(app.otherElements["PBMVideoView"], testCase: testCase, reason: "Video is not displayed")
            assertElementExists(app.buttons["Learn More"], testCase: testCase, reason: "Learn more button is not displayed")
            assertElementExists(app.buttons["PBMCloseButton"], testCase: testCase, reason: "Video close button is not displayed")
        }
    }
}

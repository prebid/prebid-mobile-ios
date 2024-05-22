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

class InterstitialAdsTest: BaseAdsTest {
    
    public func testInAppInterstitialAd() {
        testAd(testCase: testCases.inAppDisplayInterstitialCase)
    }
    
    public func testGamOriginalInterstitialAd() {
        testAd(testCase: testCases.gamOriginalDisplayInterstitialCase)
    }
    
    public func testGamRenderingInterstitialAd() {
        testAd(testCase: testCases.gamDisplayInterstitialCase)
    }
    
    public func testAdMobInterstitialAd() {
        testAd(testCase: testCases.adMobDisplayInterstitialCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(app.webViews.element.waitForExistence(timeout: 10),assertFailedMessage(testCase: testCase,reason: "Interstitial Web View is not displayed"))
        let closeButton = testCase == testCases.gamOriginalDisplayInterstitialCase ? "Close Advertisement" : "PBMCloseButton"
        XCTAssert(app.buttons[closeButton].waitForExistence(timeout: 10), assertFailedMessage(testCase: testCase,reason: "Close button is not displayed"))
    }
}

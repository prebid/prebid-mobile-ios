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

class NativeAdsTest: BaseAdsTest {
    
    public func testInAppNativeAd() {
        testAd(testCase: testCases.inAppNativeCase)
    }
    
    public func testGamOriginalNativeAd() {
        testAd(testCase: testCases.gamOriginalNativeCase)
    }
    
    public func testGamRenderingNativeAd() {
        testAd(testCase: testCases.gamNativeCase)
    }
    
    public func testAdMobNativeAd() {
        testAd(testCase: testCases.adMobNativeCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(app.staticTexts["Prebid (Title)"].waitForExistence(timeout: 10),assertFailedMessage(testCase: testCase, reason: "Prebid title is not displayed"))
    }
}

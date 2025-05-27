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

class BannerAdsTest: BaseAdsTest {
    
    private var labelText: String?
    
    override func tearDown() {
        labelText = nil
    }
    
    public func testInAppBannerAd() {
        testAd(testCase: testCases.inAppDisplayBannerCase)
    }
    
    public func testInAppBannerAdCustomRenderer() {
        labelText = "Custom Renderer"
        testAd(testCase: testCases.inAppDisplayBannerCustomRendererCase)
    }
    
    public func testGamOriginalBannerAd() {
        labelText = "Test mode"
        testAd(testCase: testCases.gamOriginalDisplayBannerCase)
    }
    
    public func testGamRenderingBannerAd() {
        testAd(testCase: testCases.gamDisplayBannerCase)
    }
    
    public func testAdMobBannerAd() {
        testAd(testCase: testCases.adMobDisplayBannerCase)
    }
    
    override func checkAd(testCase: String) {
        XCTAssert(
            app.webViews.element.waitForExistence(timeout: 10),
            assertFailedMessage(testCase: testCase,reason: "Banner Web View is not displayed")
        )
        
        if let labelText {
            XCTAssert(
                app.staticTexts[labelText].waitForExistence(timeout: 10),
                assertFailedMessage(testCase: testCase, reason: "`\(labelText)` is not displayed")
            )
        }
    }
}

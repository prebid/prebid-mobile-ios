/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class MultiformatAdsTest: BaseAdsTest {
    
    func testMultiformatInAppNativeAd() {
        testAd(testCase: testCases.gamOriginalMultiformatInAppNativeCase)
    }
    
    func testMultiformatNativeStylesAd() {
        testAd(testCase: testCases.gamOriginalMultiformatNativeStylesCase)
    }
    
    override func checkAd(testCase: String) {
        if testCase == testCases.gamOriginalMultiformatInAppNativeCase {
            let configIdElement = app.staticTexts.element(matching: .any, identifier: "configIdLabel")
            assertElementExists(
                configIdElement,
                testCase: testCase,
                reason: "Config ID is not displayed"
            )
            
            let configId = configIdElement.label
            
            if configId.contains("banner") && !configId.contains("native") {
                assertElementExists(app.webViews.element, testCase: testCase, reason: "Banner Web View is not displayed")
                assertElementExists(app.staticTexts["Test mode"], testCase: testCase, reason: "Test mode is not displayed")
            } else if configId.contains("video") {
                assertElementExists(app.buttons["Play video"], testCase: testCase, reason: "Play video button is not displayed")
            } else if configId.contains("native") {
                assertElementExists(app.staticTexts["Prebid (Title)"], testCase: testCase, reason: "Prebid title is not displayed")
            } else {
                XCTFail(assertFailedMessage(testCase: testCase, reason: "Undefined ad format. Check config id."))
            }
        } else if testCase == testCases.gamOriginalMultiformatNativeStylesCase {
            assertElementExists(app.webViews.element, testCase: testCase, reason: "Banner Web View is not displayed")
            assertElementExists(app.staticTexts["Test mode"], testCase: testCase, reason: "Test mode is not displayed")
        }
    }
}

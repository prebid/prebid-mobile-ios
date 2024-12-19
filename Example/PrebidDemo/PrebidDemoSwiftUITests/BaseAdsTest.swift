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

class BaseAdsTest: XCTestCase {
    
    let app = XCUIApplication()
    let testCases = TestCases()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-integrationKindAll", "-uiTesting"]
    }
    
    func testAd(testCase: String) {
        goToAd(testCase: testCase)
        checkAd(testCase: testCase)
    }
    
    func checkAd(testCase: String) {}
    
    func assertFailedMessage(testCase: String, reason: String) -> String {
        return "Ad Failed \(testCase): \(reason)"
    }
    
    private func goToAd(testCase: String) {
        app.launch()
        app.searchFields.element.tap()
        app.searchFields.element.typeText(testCase)
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
    }
}

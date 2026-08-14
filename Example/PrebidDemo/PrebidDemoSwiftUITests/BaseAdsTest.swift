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

    private enum Timeout {
        static let navigation: TimeInterval = 15
        static let adLoad: TimeInterval = 30
    }

    private static let adStatusAccessibilityIdentifier = "prebid-demo-ad-status"
    
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

    func assertElementExists(
        _ element: XCUIElement,
        testCase: String,
        reason: String,
        timeout: TimeInterval = Timeout.adLoad
    ) {
        let adStatus = app.otherElements[Self.adStatusAccessibilityIdentifier]
        let outcomePredicate = NSPredicate { _, _ in
            element.exists || Self.failureMessage(from: adStatus) != nil
        }
        let outcomeExpectation = XCTNSPredicateExpectation(predicate: outcomePredicate, object: nil)
        let outcome = XCTWaiter.wait(for: [outcomeExpectation], timeout: timeout)

        if let failureMessage = Self.failureMessage(from: adStatus) {
            XCTFail(assertFailedMessage(testCase: testCase, reason: failureMessage))
            return
        }

        XCTAssertEqual(
            outcome,
            .completed,
            assertFailedMessage(testCase: testCase, reason: reason)
        )
        XCTAssertTrue(
            element.exists,
            assertFailedMessage(testCase: testCase, reason: reason)
        )
    }
    
    private func goToAd(testCase: String) {
        app.launch()

        let searchField = app.searchFields.element
        XCTAssertTrue(
            searchField.waitForExistence(timeout: Timeout.navigation),
            "Search field is not displayed"
        )
        searchField.tap()
        searchField.typeText(testCase)

        let firstMatchingCase = app.tables.element(boundBy: 0).cells.element(boundBy: 0)
        XCTAssertTrue(
            firstMatchingCase.waitForExistence(timeout: Timeout.navigation),
            "Integration case '\(testCase)' is not displayed"
        )
        firstMatchingCase.tap()
    }

    private static func failureMessage(from statusElement: XCUIElement) -> String? {
        guard statusElement.exists,
              let status = statusElement.value as? String,
              status.hasPrefix("failed: ") else {
            return nil
        }

        return String(status.dropFirst("failed: ".count))
    }
}

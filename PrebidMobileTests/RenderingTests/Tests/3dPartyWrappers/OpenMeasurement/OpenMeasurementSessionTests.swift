/*   Copyright 2018-2025 Prebid.org, Inc.

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
import WebKit

@testable import PrebidMobile

class OpenMeasurementSessionTests: XCTestCase {

    private var logToFile: LogToFileLock?

    override func setUp() {
        super.setUp()
        logToFile = .init()
    }

    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }

    private func makeRealSession(webView: WKWebView) throws -> OpenMeasurementSession {
        let wrapper = OpenMeasurementWrapper()
        return try XCTUnwrap(wrapper.initializeWebViewSession(webView, contentUrl: nil) as? OpenMeasurementSession)
    }

    /// OMID returns NO with no error object for an obstruction that was already added: that is not an error and the
    /// ObjC original logged nothing for it (MRAIDController re-adds the same views on resize/expand).
    func testAddingSameFriendlyObstructionTwiceDoesNotLog() throws {
        let webView = WKWebView()
        let session = try makeRealSession(webView: webView)
        let obstruction = UIView()

        session.addFriendlyObstruction(obstruction, purpose: .modalViewControllerClose)
        XCTAssertFalse((Log.getLogFileAsString() ?? "").contains("‼️"), "First add must not log an error")

        session.addFriendlyObstruction(obstruction, purpose: .modalViewControllerClose)
        XCTAssertFalse((Log.getLogFileAsString() ?? "").contains("‼️"), "Duplicate add must not log an error")
        withExtendedLifetime(webView) {}
    }

    /// A genuine OMID error (a detailed reason longer than 50 characters) is still logged.
    func testFriendlyObstructionWithTooLongDetailedReasonLogs() throws {
        let webView = WKWebView()
        let session = try makeRealSession(webView: webView)

        session.addFriendlyObstruction(UIView(),
                                       obstructionType: .other,
                                       detailedReason: String(repeating: "a", count: 51))

        XCTAssertTrue((Log.getLogFileAsString() ?? "").contains("‼️"))
        withExtendedLifetime(webView) {}
    }
}

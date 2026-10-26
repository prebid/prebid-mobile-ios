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

import UIKit
import WebKit
import XCTest

@testable import PrebidMobile

class SetupTests: NSObject, XCTestObservation {

    private static var warmUpWebView: WKWebView?

    override init() {
        super.init()
        MockServer.shared.connectionIDHeaderKey = PrebidServerConnection.internalIDKey
        SetupTests.seedUserAgent()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    /// `UserAgentService` resolves the user agent through a `WKWebView`, and `PBMBidRequester`
    /// awaits that resolution before *every* request — including ones that only return a
    /// validation error. On a cold CI simulator WebKit's GPU/WebContent helper processes have been
    /// observed taking over 170 seconds to launch, which times out every suite that requests bids.
    /// Seeding the persisted user agent keeps those suites off WebKit entirely.
    /// `UserAgentServiceTest` still exercises the real `WKWebView` path through its own instances.
    private static func seedUserAgent() {
        let store = UserAgentDefaults()

        guard store.userAgent?.isEmpty ?? true else { return }

        store.userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS "
            + UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            + " like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }

    /// Cold simulator helper processes can take longer than an individual test's deadline.
    /// Finish startup before running tests, and retain the page until the bundle finishes so
    /// WebKit does not shut down between suites. A startup failure is logged, not fatal: a crash
    /// here ends the run before any test reports, and `-retry-tests-on-failure` cannot restart it.
    /// Tests that need WebKit still fail on their own deadlines and are retried individually.
    func testBundleWillStart(_ testBundle: Bundle) {
        let ready = XCTestExpectation(description: "WebKit helper processes ready")
        var startupError: Error?
        let start = {
            let webView = WKWebView()
            Self.warmUpWebView = webView
            webView.evaluateJavaScript("navigator.userAgent") { result, error in
                startupError = error
                if error == nil, (result as? String)?.isEmpty != false {
                    startupError = NSError(domain: "SetupTests", code: 1,
                                           userInfo: [NSLocalizedDescriptionKey: "WebKit returned no user agent"])
                }
                ready.fulfill()
            }
        }
        if Thread.isMainThread {
            start()
        } else {
            DispatchQueue.main.async(execute: start)
        }
        // This is the simulator startup budget; individual test deadlines remain unchanged.
        let startupBudget: TimeInterval = 180
        let result = XCTWaiter.wait(for: [ready], timeout: startupBudget)
        if result != .completed {
            print("⚠️ WebKit startup did not finish within \(Int(startupBudget)) seconds; continuing (XCTWaiter result \(result.rawValue))")
        } else if let startupError {
            print("⚠️ WebKit startup failed; continuing: \(startupError.localizedDescription)")
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        Self.warmUpWebView = nil
        XCTestObservationCenter.shared.removeTestObserver(self)
    }
}

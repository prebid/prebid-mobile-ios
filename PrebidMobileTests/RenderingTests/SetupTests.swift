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

@testable import PrebidMobile

class SetupTests: NSObject {

    private static var warmUpWebView: WKWebView?

    override init() {
        MockServer.shared.connectionIDHeaderKey = PrebidServerConnection.internalIDKey
        SetupTests.seedUserAgent()
        SetupTests.warmUpWebKit()
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

    /// Seeding the user agent above removes the side effect that used to start WebKit's helper
    /// processes at bundle load. Suites that genuinely need a `WKWebView` (`UserAgentServiceTest`,
    /// the MRAID/HTML creative tests) wait on those launches with short timeouts, so kick them off
    /// here — fire and forget — to keep the warm-up head start.
    private static func warmUpWebKit() {
        DispatchQueue.main.async {
            let webView = WKWebView()
            warmUpWebView = webView
            webView.evaluateJavaScript("navigator.userAgent") { _, _ in
                warmUpWebView = nil
            }
        }
    }
}

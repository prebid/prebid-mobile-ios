/*   Copyright 2018-2021 Prebid.org, Inc.

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

import WebKit

// Breaks the retain cycle that WKUserContentController creates on its message handlers.
// See: https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
@objc(PBMWKScriptMessageHandlerLeakAvoider)
public class WKScriptMessageHandlerLeakAvoider: NSObject, WKScriptMessageHandler {

    @objc public weak var delegate: WKScriptMessageHandler?

    @objc(initWithDelegate:)
    public init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

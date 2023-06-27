//
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

import Foundation
import WebKit

@objc(PBMHiddenWebViewManager) @objcMembers
public class HiddenWebViewManager: NSObject {
    
    private var hiddenWebView: WKWebView
    
    private let landingPageURL: URL?
    
    public init(webView: WKWebView, landingPageString: String) {
        hiddenWebView = webView
        landingPageURL = URL(string: landingPageString)
        super.init()
    }
    
    public func openHiddenWebView() {
        guard let landingPageURL = landingPageURL else {
            Log.error("landingPageURL is not valid.")
            return
        }
        let request = URLRequest(url: landingPageURL)
        hiddenWebView.load(request)
    }
}

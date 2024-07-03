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

import WebKit

@objc(PBMUserAgentService) @objcMembers
public class UserAgentService: NSObject {
    
    public static let shared = UserAgentService()
    
    public private(set) var userAgent: String = ""
    
    private var webViews = [WKWebView]()

    override init() {
        super.init()
        fetchUserAgent()
    }
    
    public func fetchUserAgent(completion: ((String) -> Void)? = nil) {
        // user agent has been already generated
        guard userAgent.isEmpty else {
            completion?(userAgent)
            return
        }
        
        DispatchQueue.main.async {
            let webView = WKWebView()
            self.webViews.append(webView)
            webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, error in
                guard let self = self else { return }
                
                if let error {
                    Log.error(error.localizedDescription)
                }
                
                if let result = result, self.userAgent.isEmpty  {
                    self.userAgent = "\(result)"
                }
                
                self.webViews.removeAll(where: { $0 == webView })
                
                completion?(self.userAgent)
            }
        }
    }
}

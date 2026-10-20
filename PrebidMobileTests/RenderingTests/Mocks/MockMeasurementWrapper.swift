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

@testable import PrebidMobile

class MockMeasurementWrapper: NSObject, OMSessionWrapper {
    
    var injectJSLibClosure: ((String) -> Void)?
    var initializeSessionClosure: ((OMSession) -> Void)?
    
    func injectJSLib(_ html: String, error: NSErrorPointer) -> String? {
        injectJSLibClosure?(html)
        error?.pointee = NSError(domain: "PrebidMobileTests", code: 0, userInfo: [NSLocalizedDescriptionKey: "PrebidMobileTests: do nothing"])
        return nil
    }
    
    func initializeWebViewSession(_ webView: WKWebView, contentUrl: String?) -> OMSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    func initializeNativeVideoSession(_ videoView: UIView, verificationParameters: VideoVerificationParameters?) -> OMSession? {
        // TODO: The same for tests?
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    func initializeNativeDisplaySession(_ view: UIView,
                                                 omidJSUrl omidJS: String,
                                                 vendorKey: String?,
                                                 parameters verificationParameters: String?) -> OMSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
}

//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import WebKit

@objc(PBMOMSessionWrapper)
public protocol OMSessionWrapper: NSObjectProtocol {
    
    func injectJSLib(_ html: String, error: NSErrorPointer) -> String?
    
    @objc(initializeWebViewSession:contentUrl:)
    func initializeWebViewSession(_ webView: WKWebView, contentUrl: String?) -> OMSession?
    
    func initializeNativeVideoSession(_ videoView: UIView, verificationParameters: VideoVerificationParameters?) -> OMSession?
    
    func initializeNativeDisplaySession(_ view: UIView,
                                        omidJSUrl: String,
                                        vendorKey: String?,
                                        parameters: String?) -> OMSession?
}

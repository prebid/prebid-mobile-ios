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

@testable import PrebidMobile

class MockMeasurementWrapper : PBMOpenMeasurementWrapper {
    
    var injectJSLibClosure: ((String) -> Void)?
    var initializeSessionClosure: ((PBMOpenMeasurementSession) -> Void)?
    
    override init() {
        
    }
    
    override func injectJSLib(_ html: String) throws -> String {
        injectJSLibClosure?(html)
        throw PBMError.error(description:"PrebidMobileTests: do nothing")
    }
    
    override func initializeWebViewSession(_ webView: UIView, contentUrl: String?) -> PBMOpenMeasurementSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    override func initializeNativeVideoSession(_ videoView: UIView, verificationParameters:PBMVideoVerificationParameters?) -> PBMOpenMeasurementSession? {
        // TODO: The same for tests?
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    override func initializeNativeDisplaySession(_ view: UIView,
                                                 omidJSUrl omidJS: String,
                                                 vendorKey: String?,
                                                 parameters verificationParameters: String?) -> PBMOpenMeasurementSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
}

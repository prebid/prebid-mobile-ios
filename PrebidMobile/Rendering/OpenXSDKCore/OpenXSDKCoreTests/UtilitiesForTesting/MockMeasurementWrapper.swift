//
//  MockOpenMeasurementWrapper.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

class MockMeasurementWrapper : OXMOpenMeasurementWrapper {

    var injectJSLibClosure: ((String) -> Void)?
    var initializeSessionClosure: ((OXMOpenMeasurementSession) -> Void)?
    
    override init() {
        
    }
    
    override func initializeJSLib(with bundle: Bundle, completion: OXMVoidBlock? = nil) {
        assertionFailure("Unsued in tests for now")
    }
    
    override func injectJSLib(_ html: String) throws -> String {
        injectJSLibClosure?(html)
        throw OXMError.error(description:"OpenXSDKCoreTests: do nothing")
    }
    
    override func initializeWebViewSession(_ webView: UIView, contentUrl: String?) -> OXMOpenMeasurementSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    override func initializeNativeVideoSession(_ videoView: UIView, verificationParameters:OXMVideoVerificationParameters?) -> OXMOpenMeasurementSession? {
        // TODO: The same for tests?
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
    
    override func initializeNativeDisplaySession(_ view: UIView,
                                                 omidJSUrl omidJS: String,
                                                 vendorKey: String?,
                                                 parameters verificationParameters: String?) -> OXMOpenMeasurementSession? {
        let session = MockMeasurementSession()
        initializeSessionClosure?(session)
        
        return session
    }
   
}

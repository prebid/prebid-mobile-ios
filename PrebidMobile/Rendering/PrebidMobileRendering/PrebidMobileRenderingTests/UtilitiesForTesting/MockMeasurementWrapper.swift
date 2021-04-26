//
//  MockOpenMeasurementWrapper.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockMeasurementWrapper : PBMOpenMeasurementWrapper {

    var injectJSLibClosure: ((String) -> Void)?
    var initializeSessionClosure: ((PBMOpenMeasurementSession) -> Void)?
    
    override init() {
        
    }
    
    override func initializeJSLib(with bundle: Bundle, completion: PBMVoidBlock? = nil) {
        assertionFailure("Unsued in tests for now")
    }
    
    override func injectJSLib(_ html: String) throws -> String {
        injectJSLibClosure?(html)
        throw PBMError.error(description:"PrebidMobileRenderingTests: do nothing")
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

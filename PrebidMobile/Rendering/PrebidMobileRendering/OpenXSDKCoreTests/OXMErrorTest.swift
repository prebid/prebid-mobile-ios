//
//  OXMErrorTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMErrorTest: XCTestCase {
    
    func testInitWithMessage() {
        let error = OXMError(message: "MyError")
        XCTAssert(error.message == "MyError")
    }
    
    func testInitWithDescription() {
        let error = OXMError.error(description: "MyErrorDescription")
        
        // Verify default values
        XCTAssert(error.domain == OXAErrorDomain)
        XCTAssert(error.code == 700)
        XCTAssert(error.userInfo["NSLocalizedDescription"] as! String == "MyErrorDescription")
    }
    
    func testInitWithMessageAndType() {        
        let errorMessage = "ERROR MESSAGE"
        let err = OXMError.error(message: errorMessage, type: .internalError)
        XCTAssert(err.localizedDescription.OXMdoesMatch(errorMessage), "error should have \(errorMessage) in its description")
    }
    
    func testCreateErrorWithDescriptionNegative() {
        var error = OXMError.createError(nil, description: "")
        XCTAssertFalse(error)
        
        error = OXMError.createError(nil, message: "", type: .invalidRequest)
        XCTAssertFalse(error)
        
        error = OXMError.createError(nil, description: "", statusCode: .generalLinear)
        XCTAssertFalse(error)
    }
}

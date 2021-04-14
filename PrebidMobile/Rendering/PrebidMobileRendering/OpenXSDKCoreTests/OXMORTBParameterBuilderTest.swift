//
//  OXMORTBParameterBuilder.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

// MARK: Test Properties

fileprivate let errorMessage = "MockedRequest.toJsonString error"

// MARK: - Mock

class MockedRequest : OXMORTBBidRequest {
    
    override func toJsonString() throws -> String {
        throw OXMError.error(message: errorMessage, type: .internalError)
    }
}

// MARK: - Test Case

class OXMORTBParameterBuilderTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testAppendBuilderParameters() {        
        let res = OXMORTBParameterBuilder.buildOpenRTB(for: OXMORTBBidRequest())!
        
        XCTAssertEqual(res.keys.count, 1)
        XCTAssertNotNil(res["openrtb"])
    }
    
    func testAppendBuilderParametersWitError() {
        logToFile = .init()
        
        OXMORTBParameterBuilder.buildOpenRTB(for: MockedRequest())
        
        let log = OXMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains(errorMessage))
    }
}

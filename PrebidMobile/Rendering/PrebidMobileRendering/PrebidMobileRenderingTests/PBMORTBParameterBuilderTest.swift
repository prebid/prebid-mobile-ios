//
//  PBMORTBParameterBuilder.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

// MARK: Test Properties

fileprivate let errorMessage = "MockedRequest.toJsonString error"

// MARK: - Mock

class MockedRequest : PBMORTBBidRequest {
    
    override func toJsonString() throws -> String {
        throw PBMError.error(message: errorMessage, type: .internalError)
    }
}

// MARK: - Test Case

class PBMORTBParameterBuilderTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testAppendBuilderParameters() {        
        let res = PBMORTBParameterBuilder.buildOpenRTB(for: PBMORTBBidRequest())!
        
        XCTAssertEqual(res.keys.count, 1)
        XCTAssertNotNil(res["openrtb"])
    }
    
    func testAppendBuilderParametersWitError() {
        logToFile = .init()
        
        PBMORTBParameterBuilder.buildOpenRTB(for: MockedRequest())
        
        let log = PBMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains(errorMessage))
    }
}

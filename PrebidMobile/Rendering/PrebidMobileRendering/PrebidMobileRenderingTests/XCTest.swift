//
//  XCTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest

extension XCTestCase {

    func fulfillOrFail(_ expectation:XCTestExpectation?, _ expectationName:String, file: StaticString = #file, line: UInt = #line) {
        guard let unwrappedExpectation = expectation else {
            XCTFail("No expectation to fulfill: \(expectationName)", file:file, line:line)
            return
        }
        
        unwrappedExpectation.fulfill()
    }
}

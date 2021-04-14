//
//  OXADFPRequestTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class OXADFPRequestTest: XCTestCase {
    func testProperties() {
        XCTAssertTrue(OXADFPBanner.classesFound)
        
        let propTests: [BasePropTest<OXADFPRequest>] = [
            DicPropTest(keyPath: \.customTargeting, value: ["key": "unknown"]),
        ]
        
        let request = OXADFPRequest()
        
        for nextTest in propTests {
            nextTest.run(object: request)
        }
    }
}

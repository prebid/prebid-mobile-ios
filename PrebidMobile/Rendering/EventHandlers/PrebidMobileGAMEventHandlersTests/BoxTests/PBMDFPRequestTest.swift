//
//  PBMDFPRequestTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class PBMDFPRequestTest: XCTestCase {
    func testProperties() {
        XCTAssertTrue(PBMDFPBanner.classesFound)
        
        let propTests: [BasePropTest<PBMDFPRequest>] = [
            DicPropTest(keyPath: \.customTargeting, value: ["key": "unknown"]),
        ]
        
        let request = PBMDFPRequest()
        
        for nextTest in propTests {
            nextTest.run(object: request)
        }
    }
}

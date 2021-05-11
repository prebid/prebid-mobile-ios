//
//  PBMDFPRequestTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class GAMRequestWrapperTest: XCTestCase {
    func testProperties() {        
        let propTests: [BasePropTest<GAMRequestWrapper>] = [
            DicPropTest(keyPath: \.customTargeting, value: ["key": "unknown"]),
        ]
        
        guard let request = GAMRequestWrapper() else {
            XCTFail()
            return
        }
        
        for nextTest in propTests {
            nextTest.run(object: request)
        }
    }
}

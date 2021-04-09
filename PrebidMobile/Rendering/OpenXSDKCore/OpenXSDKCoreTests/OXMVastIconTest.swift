//
//  OXMVastIconTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMVastIconTest: XCTestCase {
    
    func testDefaultState() {
        let icon = OXMVastIcon()
        
        XCTAssertNotNil(icon.program)
        XCTAssertEqual(icon.program, "")

        XCTAssertEqual(icon.width, 0)
        XCTAssertEqual(icon.height, 0)
        XCTAssertEqual(icon.xPosition, 0)
        XCTAssertEqual(icon.yPosition, 0)
        XCTAssertEqual(icon.startOffset, 0)
        XCTAssertEqual(icon.duration, 0)
        
        
        XCTAssertNil(icon.clickThroughURI)
        XCTAssertEqual(icon.clickTrackingURIs as! [String], [String]())
        XCTAssertNil(icon.viewTrackingURI)
        
        // computed later
        XCTAssertFalse(icon.displayed)
        
        // OXMVastResourceContainer
        XCTAssertEqual(icon.resourceType, OXMVastResourceType.staticResource)
        XCTAssertNil(icon.resource)
        XCTAssertNil(icon.staticType)
    }
}

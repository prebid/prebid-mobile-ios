//
//  OpenXPathBuildersTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OpenXPathBuildersTest: XCTestCase {
    
    func testBaseURKPathBuilderBase() {
        XCTAssertEqual(OXMPathBuilder.buildBaseURL(forDomain: "d1"), "https://d1")
        XCTAssertEqual(OXMPathBuilder.buildBaseURL(forDomain: ""), "https://")
        XCTAssertEqual(OXMPathBuilder.buildBaseURL(forDomain: "😃"), "https://😃")
    }

    func testURLPathBuilderBase() {
        XCTAssertEqual(OXMPathBuilder.buildURLPath(forDomain: "d1", path: "tt"), "https://d1/tt/1.0/")
        XCTAssertEqual(OXMPathBuilder.buildURLPath(forDomain: "", path: "ma"), "https:///ma/1.0/")
        XCTAssertEqual(OXMPathBuilder.buildURLPath(forDomain: "😃", path: "v"), "https://😃/v/1.0/")
    }

    func testACJPathBuilder() {
        XCTAssertEqual(OXMPathBuilder.buildACJURLPath(forDomain: "d1"), "https://d1/ma/1.0/acj")
        XCTAssertEqual(OXMPathBuilder.buildACJURLPath(forDomain: ""), "https:///ma/1.0/acj")
        XCTAssertEqual(OXMPathBuilder.buildACJURLPath(forDomain: "😃"), "https://😃/ma/1.0/acj")
    }
    
    func testVASTPathBuilder() {
        XCTAssertEqual(OXMPathBuilder.buildVASTURLPath(forDomain: "d1"), "https://d1/v/1.0/av")
        XCTAssertEqual(OXMPathBuilder.buildVASTURLPath(forDomain: ""), "https:///v/1.0/av")
        XCTAssertEqual(OXMPathBuilder.buildVASTURLPath(forDomain: "😃"), "https://😃/v/1.0/av")
    }
}

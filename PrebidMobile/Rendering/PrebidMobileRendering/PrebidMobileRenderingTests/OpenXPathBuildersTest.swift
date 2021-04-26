//
//  OpenXPathBuildersTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OpenXPathBuildersTest: XCTestCase {
    
    func testBaseURKPathBuilderBase() {
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: "d1"), "https://d1")
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: ""), "https://")
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: "😃"), "https://😃")
    }

    func testURLPathBuilderBase() {
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "d1", path: "tt"), "https://d1/tt/1.0/")
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "", path: "ma"), "https:///ma/1.0/")
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "😃", path: "v"), "https://😃/v/1.0/")
    }

    func testACJPathBuilder() {
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: "d1"), "https://d1/ma/1.0/acj")
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: ""), "https:///ma/1.0/acj")
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: "😃"), "https://😃/ma/1.0/acj")
    }
    
    func testVASTPathBuilder() {
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: "d1"), "https://d1/v/1.0/av")
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: ""), "https:///v/1.0/av")
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: "😃"), "https://😃/v/1.0/av")
    }
}

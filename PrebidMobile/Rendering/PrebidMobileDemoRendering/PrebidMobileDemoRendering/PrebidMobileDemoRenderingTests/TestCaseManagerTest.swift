//
//  TestCaseManagerTest.swift
//  OpenXInternalTestAppTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileDemoRendering

class TestCaseManagerTest: XCTestCase {

    func testNames() {
            let manager = TestCaseManager()
            
            let tagMarkers: [(tag: TestCaseTag, nameFragment: String)] = [
                (.inapp, "(PPM)"),
                (.gam, "(GAM)"),
                (.mopub, "(MoPub)"),
            ]
            
            for testCase in manager.testCases {
                for testTag in tagMarkers {
                    XCTAssertEqual(testCase.title.contains(testTag.nameFragment),
                                   testCase.tags.contains(testTag.tag),
                                   "\(testCase.title): \(testCase.tags.map { "\($0)" }.joined(separator: ", ")) ?")
                }
            }
        }

}

//
//  PBMNativeAssetTitleTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAssetTitleTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let title = PBMNativeAssetTitle(length: 25)
        title.required = true
        try! title.setAssetExt(["topKey": "topVal"])
        try! title.setTitleExt(["boxedKey": "boxedVal"])
        title.assetID = 42
        let clone = title.copy() as! PBMNativeAssetTitle
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "title": [
                "len": 25,
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertNoThrow {
            XCTAssertEqual(try clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"required":1,"title":{"ext":{"boxedKey":"boxedVal"},"len":25}}
""")
        }
    }
}

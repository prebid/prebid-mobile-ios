//
//  NativeAssetDataTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAssetDataTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let data = NativeAssetData(dataType: .desc)
        data.length = 25
        data.required = true
        try! data.setAssetExt(["topKey": "topVal"])
        try! data.setDataExt(["boxedKey": "boxedVal"])
        data.assetID = 42
        let clone = data.copy() as! NativeAssetData
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "data": [
                "type": 2,
                "len": 25,
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertNoThrow {
            XCTAssertEqual(try clone.toJsonString(), """
{"data":{"ext":{"boxedKey":"boxedVal"},"len":25,"type":2},"ext":{"topKey":"topVal"},"id":42,"required":1}
""")
        }
    }
}

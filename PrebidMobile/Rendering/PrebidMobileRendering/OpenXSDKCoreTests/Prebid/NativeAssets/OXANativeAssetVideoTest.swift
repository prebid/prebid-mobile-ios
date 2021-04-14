//
//  OXANativeAssetVideoTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAssetVideoTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let title = OXANativeAssetVideo(mimeTypes: ["image/png","image/jpeg"],
                                        minDuration: 29,
                                        maxDuration: 42,
                                        protocols: [1,2,5])
        title.required = true
        try! title.setAssetExt(["topKey": "topVal"])
        try! title.setVideoExt(["boxedKey": "boxedVal"])
        title.assetID = 42
        let clone = title.copy() as! OXANativeAssetVideo
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "video": [
                "mimes": ["image/png","image/jpeg"],
                "minDuration": 29,
                "maxDuration": 42,
                "protocols": [1,2,5],
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertEqual(try? clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"required":1,"video":{"ext":{"boxedKey":"boxedVal"},"maxDuration":42,"mimes":["image\\/png","image\\/jpeg"],"minDuration":29,"protocols":[1,2,5]}}
""")
    }
}

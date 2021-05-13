//
//  PBMNativeAssetTitleTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAssetImageTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let image = NativeAssetImage()
        image.imageType = PBMImageAssetType.main.rawValue as NSNumber
        image.width = 120
        image.height = 240
        image.widthMin = 96
        image.heightMin = 128
        image.mimeTypes = ["image/png","image/jpeg"]
        image.required = 1
        try! image.setAssetExt(["topKey": "topVal"])
        try! image.setImageExt(["boxedKey": "boxedVal"])
        image.assetID = 42
        let clone = image.copy() as! NativeAssetImage
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "img": [
                "type": 3,
                "w": 120,
                "h": 240,
                "wmin": 96,
                "hmin": 128,
                "mimes": [
                    "image/png",
                    "image/jpeg",
                ],
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertEqual(try? clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"img":{"ext":{"boxedKey":"boxedVal"},"h":240,"hmin":128,"mimes":["image\\/png","image\\/jpeg"],"type":3,"w":120,"wmin":96},"required":1}
""")
    }
}

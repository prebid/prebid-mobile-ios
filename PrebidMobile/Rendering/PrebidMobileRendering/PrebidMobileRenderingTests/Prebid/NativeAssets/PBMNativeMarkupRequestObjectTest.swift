//
//  PBMNativeMarkupRequestObjectTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeMarkupRequestObjectTest: XCTestCase {
    private let defVer = "1.2"
    
    func testMarkupRequestObjectInitToJson() {
        let desc = PBMNativeAssetData(dataType: .desc)
        let markupObject = PBMNativeMarkupRequestObject.init(assets:[desc])
        
        XCTAssertEqual(markupObject.version, defVer)
        XCTAssertNil(markupObject.context)
        XCTAssertNil(markupObject.contextsubtype)
        XCTAssertNil(markupObject.plcmttype)
        XCTAssertNil(markupObject.plcmtcnt)
        XCTAssertNil(markupObject.seq)
        XCTAssertEqual(markupObject.assets as NSArray, [desc] as NSArray)
        XCTAssertNil(markupObject.aurlsupport)
        XCTAssertNil(markupObject.durlsupport)
        XCTAssertNil(markupObject.eventtrackers)
        XCTAssertNil(markupObject.privacy)
        XCTAssertNil(markupObject.ext)
        
        XCTAssertEqual(markupObject.jsonDictionary as NSDictionary?, [
            "ver": defVer,
            "assets": [
                desc.jsonDictionary,
            ],
        ] as NSDictionary)
        
        XCTAssertEqual(try? markupObject.toJsonString(), """
{"assets":[\(try! desc.toJsonString())],"ver":"\(defVer)"}
""")
        
        markupObject.version = nil
        
        XCTAssertEqual(markupObject.jsonDictionary as NSDictionary?, [
            "assets": [
                desc.jsonDictionary,
            ],
        ] as NSDictionary)
        
        XCTAssertEqual(try? markupObject.toJsonString(), """
{"assets":[\(try! desc.toJsonString())]}
""")
        
        let title = PBMNativeAssetTitle(length: 25)
        let markupObject2 = PBMNativeMarkupRequestObject(assets: [desc, title])
        
        XCTAssertEqual(markupObject2.assets as NSArray, [desc, title] as NSArray)
        
        XCTAssertEqual(markupObject2.jsonDictionary as NSDictionary?, [
            "ver": defVer,
            "assets": [
                desc.jsonDictionary,
                title.jsonDictionary,
            ],
        ] as NSDictionary)
        
        XCTAssertEqual(try? markupObject2.toJsonString(), """
{"assets":[\(try! desc.toJsonString()),\(try! title.toJsonString())],"ver":"\(defVer)"}
""")
    }
    
    func testMarkupRequestCopyToJsonString() {
        let desc = PBMNativeAssetData(dataType: .desc)
        let markupObject = PBMNativeMarkupRequestObject.init(assets:[desc])
        
        let title = PBMNativeAssetTitle(length: 25)
        let impTraker = PBMNativeEventTracker(event: .impression,
                                              methods: [NSNumber(value: PBMNativeEventTrackingMethod.JS.rawValue)])
        
        let testVer = "7.13"
        XCTAssertNotEqual(markupObject.version, testVer)
        markupObject.version = testVer
        markupObject.context = NSNumber(value: PBMNativeContextType.product.rawValue)
        markupObject.contextsubtype = NSNumber(value: PBMNativeContextSubtype.applicationStore.rawValue)
        markupObject.plcmttype = NSNumber(value: PBMNativePlacementType.outsideCoreContent.rawValue)
        markupObject.plcmtcnt = 13
        markupObject.seq = 7
        markupObject.assets = [desc, title]
        markupObject.aurlsupport = true
        markupObject.durlsupport = true
        markupObject.eventtrackers = [impTraker]
        markupObject.privacy = true
        try! markupObject.setExt(["theKey": "theValue"])
        
        let clone = markupObject.copy() as! PBMNativeMarkupRequestObject
        
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "ver": testVer,
            "context": PBMNativeContextType.product.rawValue,
            "contextsubtype": PBMNativeContextSubtype.applicationStore.rawValue,
            "plcmttype": PBMNativePlacementType.outsideCoreContent.rawValue,
            "plcmtcnt": 13,
            "seq": 7,
            "assets": [
                desc.jsonDictionary,
                title.jsonDictionary,
            ],
            "aurlsupport": 1,
            "durlsupport": 1,
            "eventtrackers": [
                impTraker.jsonDictionary,
            ],
            "privacy": 1,
            "ext": [
                "theKey": "theValue"
            ],
        ] as NSDictionary)
        
        XCTAssertEqual(try? clone.toJsonString(), """
{"assets":[\(try! desc.toJsonString()),\(try! title.toJsonString())],"aurlsupport":1,"context":\(PBMNativeContextType.product.rawValue),"contextsubtype":\(PBMNativeContextSubtype.applicationStore.rawValue),"durlsupport":1,"eventtrackers":[\(try! impTraker.toJsonString())],"ext":{"theKey":"theValue"},"plcmtcnt":13,"plcmttype":\(PBMNativePlacementType.outsideCoreContent.rawValue),"privacy":1,"seq":7,"ver":"\(testVer)"}
""")
        
    }
}

//
//  OXANativeMarkupRequestObjectTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeMarkupRequestObjectTest: XCTestCase {
    private let defVer = "1.2"
    
    func testMarkupRequestObjectInitToJson() {
        let desc = OXANativeAssetData(dataType: .desc)
        let markupObject = OXANativeMarkupRequestObject.init(assets:[desc])
        
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
        
        let title = OXANativeAssetTitle(length: 25)
        let markupObject2 = OXANativeMarkupRequestObject(assets: [desc, title])
        
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
        let desc = OXANativeAssetData(dataType: .desc)
        let markupObject = OXANativeMarkupRequestObject.init(assets:[desc])
        
        let title = OXANativeAssetTitle(length: 25)
        let impTraker = OXANativeEventTracker(event: .impression,
                                              methods: [NSNumber(value: OXANativeEventTrackingMethod.JS.rawValue)])
        
        let testVer = "7.13"
        XCTAssertNotEqual(markupObject.version, testVer)
        markupObject.version = testVer
        markupObject.context = NSNumber(value: OXANativeContextType.product.rawValue)
        markupObject.contextsubtype = NSNumber(value: OXANativeContextSubtype.applicationStore.rawValue)
        markupObject.plcmttype = NSNumber(value: OXANativePlacementType.outsideCoreContent.rawValue)
        markupObject.plcmtcnt = 13
        markupObject.seq = 7
        markupObject.assets = [desc, title]
        markupObject.aurlsupport = true
        markupObject.durlsupport = true
        markupObject.eventtrackers = [impTraker]
        markupObject.privacy = true
        try! markupObject.setExt(["theKey": "theValue"])
        
        let clone = markupObject.copy() as! OXANativeMarkupRequestObject
        
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "ver": testVer,
            "context": OXANativeContextType.product.rawValue,
            "contextsubtype": OXANativeContextSubtype.applicationStore.rawValue,
            "plcmttype": OXANativePlacementType.outsideCoreContent.rawValue,
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
{"assets":[\(try! desc.toJsonString()),\(try! title.toJsonString())],"aurlsupport":1,"context":\(OXANativeContextType.product.rawValue),"contextsubtype":\(OXANativeContextSubtype.applicationStore.rawValue),"durlsupport":1,"eventtrackers":[\(try! impTraker.toJsonString())],"ext":{"theKey":"theValue"},"plcmtcnt":13,"plcmttype":\(OXANativePlacementType.outsideCoreContent.rawValue),"privacy":1,"seq":7,"ver":"\(testVer)"}
""")
        
    }
}

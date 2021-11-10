/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import XCTest

@testable import PrebidMobile

class PBMNativeMarkupRequestObjectTest: XCTestCase {
    private let defVer = "1.2"
    
    func testMarkupRequestObjectInitToJson() {
        let desc = PBRNativeAssetData(dataType: .desc)
        let markupObject = NativeMarkupRequestObject.init(assets:[desc])
        
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
        
        let title = PBRNativeAssetTitle(length: 25)
        let markupObject2 = NativeMarkupRequestObject(assets: [desc, title])
        
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
        let desc = PBRNativeAssetData(dataType: .desc)
        let markupObject = NativeMarkupRequestObject.init(assets:[desc])
        
        let title = PBRNativeAssetTitle(length: 25)
        let impTraker = PBRNativeEventTracker(event: NativeEventType.impression.rawValue,
                                           methods: [NativeEventTrackingMethod.js.rawValue])
        
        let testVer = "7.13"
        XCTAssertNotEqual(markupObject.version, testVer)
        markupObject.version = testVer
        markupObject.context = NativeContextType.product.rawValue
        markupObject.contextsubtype = NativeContextSubtype.applicationStore.rawValue
        markupObject.plcmttype = NativePlacementType.outsideCoreContent.rawValue
        markupObject.plcmtcnt = 13
        markupObject.seq = 7
        markupObject.assets = [desc, title]
        markupObject.aurlsupport = 1
        markupObject.durlsupport = 1
        markupObject.eventtrackers = [impTraker]
        markupObject.privacy = 1
        try! markupObject.setExt(["theKey": "theValue"])
        
        let clone = markupObject.copy() as! NativeMarkupRequestObject
        
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "ver": testVer,
            "context": NativeContextType.product.rawValue,
            "contextsubtype": NativeContextSubtype.applicationStore.rawValue,
            "plcmttype": NativePlacementType.outsideCoreContent.rawValue,
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
{"assets":[\(try! desc.toJsonString()),\(try! title.toJsonString())],"aurlsupport":1,"context":\(NativeContextType.product.rawValue),"contextsubtype":\(NativeContextSubtype.applicationStore.rawValue),"durlsupport":1,"eventtrackers":[\(try! impTraker.toJsonString())],"ext":{"theKey":"theValue"},"plcmtcnt":13,"plcmttype":\(NativePlacementType.outsideCoreContent.rawValue),"privacy":1,"seq":7,"ver":"\(testVer)"}
""")
        
    }
}

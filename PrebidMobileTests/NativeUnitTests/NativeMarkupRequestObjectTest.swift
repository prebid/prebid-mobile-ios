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

class NativeMarkupRequestObjectTest: XCTestCase {
    
    func testMarkupRequestObjectInitToJson() throws {
        let markupObject = NativeMarkupRequestObject.init()
        
        XCTAssertNil(markupObject.context)
        XCTAssertNil(markupObject.contextsubtype)
        XCTAssertNil(markupObject.plcmttype)
        XCTAssertTrue(markupObject.plcmtcnt == 1)
        XCTAssertTrue(markupObject.seq == 0)
        XCTAssertNil(markupObject.assets)
        XCTAssertTrue(markupObject.aurlsupport == 0)
        XCTAssertTrue(markupObject.durlsupport == 0)
        XCTAssertNil(markupObject.eventtrackers)
        XCTAssertTrue(markupObject.privacy == 0)
        XCTAssertNil(markupObject.ext)
        
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        markupObject.eventtrackers = [eventTracker]
        
        let assettitle = NativeAssetTitle(length:25, required: true)
        XCTAssertTrue(assettitle.length == 25)
        let ext = ["key" : "value"]
        assettitle.ext = ext as AnyObject
        if let data = assettitle.ext as? [String : String], let value = data["key"] {
            XCTAssertTrue(value == "value")
        }
        
        markupObject.assets = [assettitle]
        let result = """
        {"assets":[{"required":1,"title":{"ext":{"key":"value"},"len":25}}],"aurlsupport":0,"durlsupport":0,"eventtrackers":[{"event":1,"methods":[1,2]}],"plcmtcnt":1,"privacy":0,"seq":0}
        """
        XCTAssertEqual(try markupObject.toJsonString(), result)
    }
}

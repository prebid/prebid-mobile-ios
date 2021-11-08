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

class PBMNativeEventTrackerTest: XCTestCase {
    func testNativeEventTracker() {
        let tracker = PBRNativeEventTracker(event: NativeEventType.impression.rawValue,
                                         methods: [NativeEventTrackingMethod.js.rawValue])
        XCTAssertEqual(tracker.event, NativeEventType.impression.rawValue)
        XCTAssertEqual(tracker.methods, [2])
        XCTAssertNil(tracker.ext)
        
        XCTAssertEqual(tracker.jsonDictionary as NSDictionary?, [
            "event": 1,
            "methods": [2],
        ] as NSDictionary)
        
        tracker.event = NativeEventType.mrc100.rawValue
        tracker.methods = [NativeEventTrackingMethod.js, NativeEventTrackingMethod.img].map { $0.rawValue }
        try? tracker.setExt([
            "someStringKey": "someValue",
            "someIntKey": 42,
        ])
        
        XCTAssertEqual(tracker.jsonDictionary as NSDictionary?, [
            "event": 3,
            "methods": [2, 1],
            "ext": [
                "someStringKey": "someValue",
                "someIntKey": 42,
            ],
        ] as NSDictionary)
        
        XCTAssertEqual(try! tracker.toJsonString(), """
{"event":3,"ext":{"someIntKey":42,"someStringKey":"someValue"},"methods":[2,1]}
""")
    }
}

//
//  PBMNativeEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeEventTrackerTest: XCTestCase {
    func testNativeEventTracker() {
        let tracker = NativeEventTracker(event: NativeEventType.impression.rawValue,
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

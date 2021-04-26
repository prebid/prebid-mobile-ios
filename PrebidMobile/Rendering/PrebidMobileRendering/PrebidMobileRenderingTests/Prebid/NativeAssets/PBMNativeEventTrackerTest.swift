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
        let tracker = PBMNativeEventTracker(event: .impression,
                                            methods: [NSNumber(value: PBMNativeEventTrackingMethod.JS.rawValue)])
        XCTAssertEqual(tracker.event, .impression)
        XCTAssertEqual(tracker.methods, [2])
        XCTAssertNil(tracker.ext)
        
        XCTAssertEqual(tracker.jsonDictionary as NSDictionary?, [
            "event": 1,
            "methods": [2],
        ] as NSDictionary)
        
        tracker.event = .MRC100
        tracker.methods = [PBMNativeEventTrackingMethod.JS, .img].map { NSNumber(value: $0.rawValue) }
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

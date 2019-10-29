//
//  NativeEventTrackerTests.swift
//  PrebidMobileTests
//
//  Created by Akash Verma on 22/10/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import XCTest
@testable import PrebidMobile

class NativeEventTrackerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

     func testNativeEventType() {
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        XCTAssertTrue(eventTracker.event == EventType.Impression)
        eventTracker.event = EventType.ViewableImpression50
        XCTAssertTrue(eventTracker.event == EventType.ViewableImpression50)
        eventTracker.event = EventType.ViewableImpression100
        XCTAssertTrue(eventTracker.event == EventType.ViewableImpression100)
        eventTracker.event = EventType.ViewableVideoImpression50
        XCTAssertTrue(eventTracker.event == EventType.ViewableVideoImpression50)
        eventTracker.event = EventType.TBD
        XCTAssertTrue(eventTracker.event == EventType.TBD)
    }
    
    func testNativeEventTracking() {
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image])
        XCTAssertTrue(eventTracker.methods?.count == 1)
        if let eventTrackerArray = eventTracker.methods{
            if eventTrackerArray.count == 1 {
                let eventTracker = eventTrackerArray[0]
                XCTAssertTrue(eventTracker == EventTracking.Image)
            }
        }
        eventTracker.methods = [EventTracking.js];
        XCTAssertTrue(eventTracker.methods?.count == 1)
        if let eventTrackerArray = eventTracker.methods{
            if eventTrackerArray.count == 1 {
                let eventTracker = eventTrackerArray[0]
                XCTAssertTrue(eventTracker == EventTracking.js)
            }
        }
        eventTracker.methods = [EventTracking.TBD];
        XCTAssertTrue(eventTracker.methods?.count == 1)
        if let eventTrackerArray = eventTracker.methods{
            if eventTrackerArray.count == 1 {
                let eventTracker = eventTrackerArray[0]
                XCTAssertTrue(eventTracker == EventTracking.TBD)
            }
        }

    }

}

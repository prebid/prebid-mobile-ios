/*   Copyright 2018-2019 Prebid.org, Inc.

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

class NativeEventTrackerTests: XCTestCase {

     func testNativeEventType() {
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        XCTAssertTrue(eventTracker.event == EventType.Impression)
        eventTracker.event = EventType.ViewableImpression50
        XCTAssertTrue(eventTracker.event == EventType.ViewableImpression50)
        eventTracker.event = EventType.ViewableImpression100
        XCTAssertTrue(eventTracker.event == EventType.ViewableImpression100)
        eventTracker.event = EventType.ViewableVideoImpression50
        XCTAssertTrue(eventTracker.event == EventType.ViewableVideoImpression50)
        eventTracker.event = EventType.Custom
        XCTAssertTrue(eventTracker.event == EventType.Custom)
    }
    
    func testNativeEventTracking() {
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image])
        XCTAssertTrue(eventTracker.methods.count == 1)
        let eventTrackerArray = eventTracker.methods
        
        if eventTrackerArray.count == 1 {
            let eventTracker = eventTrackerArray[0]
            XCTAssertTrue(eventTracker == EventTracking.Image)
            
        }
        
        eventTracker.methods = [EventTracking.js];
        XCTAssertTrue(eventTracker.methods.count == 1)
        
        eventTracker.methods = [EventTracking.Custom];
        XCTAssertTrue(eventTracker.methods.count == 1)
        
    }

}

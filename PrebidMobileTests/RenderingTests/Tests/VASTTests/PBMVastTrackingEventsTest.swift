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

class PBMVastTrackingEventsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let trackEvents1 = PBMVastTrackingEvents()
        XCTAssert(trackEvents1.trackingEvents.count == 0)
        XCTAssert(trackEvents1.progressOffsets.count == 0)
        
    }
    
    func testAddTrackingURL() {
        let trackEvents1 = PBMVastTrackingEvents()
        
        trackEvents1.addTrackingURL(nil, event: "event", attributes: nil)
        XCTAssert(trackEvents1.trackingEvents.count == 0, "Incorrect number of trackingEvents found.")
        XCTAssert(trackEvents1.progressOffsets.count == 0, "Incorrect number of progressOffsets found.")
        
        trackEvents1.addTrackingURL("url1", event: nil, attributes: nil)
        XCTAssert(trackEvents1.trackingEvents.count == 0, "Incorrect number of trackingEvents found.")
        XCTAssert(trackEvents1.progressOffsets.count == 0, "Incorrect number of progressOffsets found.")
        
        trackEvents1.addTrackingURL("url1", event: "event", attributes: nil)
        // will store the event, regardless if attributes exist.
        XCTAssert(trackEvents1.trackingEvents.count == 1, "Incorrect number of trackingEvents found.")
        XCTAssert(trackEvents1.progressOffsets.count == 0, "Incorrect number of progressOffsets found.")
        
        trackEvents1.addTrackingURL("url1", event: "progress", attributes: nil)
        // will store the event, regardless if attributes exist.
        XCTAssert(trackEvents1.trackingEvents.count == 2, "Incorrect number of trackingEvents found.")
        XCTAssert(trackEvents1.progressOffsets.count == 0, "Incorrect number of progressOffsets found.")
        
        let attrArry = [String:String]()
        trackEvents1.addTrackingURL("url", event: "progress", attributes: attrArry)
        // will store the event & progress.
        XCTAssert(trackEvents1.trackingEvents.count == 2, "Incorrect number of trackingEvents found.")
        XCTAssert(trackEvents1.progressOffsets.count == 1, "Incorrect number of progressOffsets found.")
        
        
    }
    
    func testTrackingURLsForEvent () {
        let trackEvents1 = PBMVastTrackingEvents()
        
        // precondition
        XCTAssert(trackEvents1.trackingEvents.count == 0)
        
        var events = trackEvents1.trackingURLs(forEvent: "event1")
        XCTAssert((events == nil),"Unexpected return value")
        
        let trackEvents2 = PBMVastTrackingEvents()
        // precondition
        XCTAssert(trackEvents2.trackingEvents.count == 0)
        let attrArry = [String:String]()
        trackEvents2.addTrackingURL("url", event: "progress", attributes: attrArry)
        
        events = trackEvents2.trackingURLs(forEvent: "progress")
        XCTAssert((events != nil),"Unexpected return value")
        XCTAssert(events?.count == 1, "Unexpected number of events returned.")
    }
}

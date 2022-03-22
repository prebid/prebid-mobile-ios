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

//This is a test of EnumSequence, NOT neccessarily a test of TrackingEvent (which was the first enum to implement EnumSequence)
class EnumSequenceTest: XCTestCase {
    
    func testPBMTrackingEvent() {
        
        let lastEvent = PBMTrackingEvent.error.rawValue
        XCTAssertEqual(lastEvent, 26)
        
        var allEvents = [PBMTrackingEvent]()
        for i in 0...lastEvent {
            allEvents.append(PBMTrackingEvent(rawValue: i)!)
        }
        
        //Some spot checking of contained values
        XCTAssert(allEvents.contains(PBMTrackingEvent.request))
        XCTAssert(allEvents.contains(PBMTrackingEvent.impression))
        XCTAssert(allEvents.contains(PBMTrackingEvent.error))
        
        for event in allEvents {
            Log.info(PBMTrackingEventDescription.getDescription(event))
        }
    }
}

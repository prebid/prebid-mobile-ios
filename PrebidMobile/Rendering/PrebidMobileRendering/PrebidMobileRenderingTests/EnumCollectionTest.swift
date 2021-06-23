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
            PBMLog.info(PBMTrackingEventDescription.getDescription(event))
        }
    }
}

import XCTest
@testable import PrebidMobileRendering

//This is a test of EnumSequence, NOT neccessarily a test of TrackingEvent (which was the first enum to implement EnumSequence)
class EnumSequenceTest: XCTestCase {

    func testOXMTrackingEvent() {
        
        let lastEvent = OXMTrackingEvent.error.rawValue
        XCTAssertEqual(lastEvent, 26)
        
        var allEvents = [OXMTrackingEvent]()
        for i in 0...lastEvent {
            allEvents.append(OXMTrackingEvent(rawValue: i)!)
        }
        
        //Some spot checking of contained values
        XCTAssert(allEvents.contains(OXMTrackingEvent.request))
        XCTAssert(allEvents.contains(OXMTrackingEvent.impression))
        XCTAssert(allEvents.contains(OXMTrackingEvent.error))
        
        for event in allEvents {
            OXMLog.info(OXMTrackingEventDescription.getDescription(event))
        }
    }
}

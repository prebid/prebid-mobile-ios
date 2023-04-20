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

class EventManagerTest: XCTestCase {
    
    private var trackersCount = 0
    
    override func setUp() {
        super.setUp()
        
        trackersCount = 0
    }
    
    func testRegisterUnregister() {
        
        let creativeTracker = EventManager()
        XCTAssertNotNil(creativeTracker.trackers)
        XCTAssertEqual(creativeTracker.trackers?.count, 0)
        
        // Add tracker
        let tracker1 = createTrackerWithExpectationCount(4)
        creativeTracker.registerTracker(tracker1)
        XCTAssertEqual(creativeTracker.trackers?.count, 1)
        
        creativeTracker.trackEvent(.impression) // expectations count: t1(1) t2(-) t3(-)
        
        // Add tracker
        let tracker2 = createTrackerWithExpectationCount(2)
        creativeTracker.registerTracker(tracker2)
        XCTAssertEqual(creativeTracker.trackers?.count, 2)
        
        creativeTracker.trackEvent(.impression) // expectations count: t1(2) t2(1) t3(-)
        
        // Add tracker
        let tracker3 = createTrackerWithExpectationCount(2)
        creativeTracker.registerTracker(tracker3)
        XCTAssertEqual(creativeTracker.trackers?.count, 3)
        
        creativeTracker.trackEvent(.impression) // expectations count: t1(3) t2(2) t3(1)
        
        // Remove "middle" tracker
        creativeTracker.unregisterTracker(tracker2)
        XCTAssertEqual(creativeTracker.trackers?.count, 2)
        
        creativeTracker.trackEvent(.impression) // expectations count: t1(4) t2(-) t3(2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testSupportAllProtocol() {
        let creativeTracker = EventManager()
        
        let exp = expectation(description:"expectation")
        exp.expectedFulfillmentCount = 4
        
        let eventTracker = MockPBMAdModelEventTracker(creativeModel: MockPBMCreativeModel(adConfiguration: AdConfiguration()), serverConnection: PrebidServerConnection())
        
        let testTrackEvent: PBMTrackingEvent = .impression
        eventTracker.mock_trackEvent = { event in
            XCTAssertEqual(testTrackEvent, event)
            exp.fulfill()
        }
        
        let testParams = PBMVideoVerificationParameters()
        eventTracker.mock_trackVideoAdLoaded = { params in
            XCTAssertTrue(testParams === params)
            exp.fulfill()
        }
        
        let testDuration: CGFloat = 42
        let testVolume: CGFloat = 3.14
        let testDeviceVolume: CGFloat = 1.618
        eventTracker.mock_trackStartVideo = { duration, volume in
            XCTAssertEqual(testDuration, duration)
            XCTAssertEqual(testVolume, volume)
            
            exp.fulfill()
        }
        
        eventTracker.mock_trackVolumeChanged = { playerVolume, deviceVolume in
            XCTAssertEqual(testVolume, playerVolume)
            XCTAssertEqual(testDeviceVolume, deviceVolume)
            
            exp.fulfill()
        }
        
        creativeTracker.registerTracker(eventTracker)
        
        creativeTracker.trackEvent(.impression)
        creativeTracker.trackVideoAdLoaded(testParams)
        creativeTracker.trackStartVideo(withDuration: testDuration, volume:testVolume)
        creativeTracker.trackVolumeChanged(testVolume, deviceVolume: testDeviceVolume)
        
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: - Helper Methods
    
    private func createTrackerWithExpectationCount(_ count: UInt) -> MockPBMAdModelEventTracker {
        let exp = expectation(description:"expectation\(trackersCount)")
        trackersCount += 1
        exp.expectedFulfillmentCount = Int(count)
        
        let eventTracker = MockPBMAdModelEventTracker(creativeModel: MockPBMCreativeModel(adConfiguration: AdConfiguration()), serverConnection: PrebidServerConnection())
        eventTracker.mock_trackEvent = { _ in
            exp.fulfill()
        }
        
        return eventTracker;
    }
}

extension EventManager {
    var mirror: Mirror {
        Mirror(reflecting: self)
    }
    
    var trackers: [PBMEventTrackerProtocol]? {
        mirror.descendant("trackers") as? [PBMEventTrackerProtocol]
    }
}

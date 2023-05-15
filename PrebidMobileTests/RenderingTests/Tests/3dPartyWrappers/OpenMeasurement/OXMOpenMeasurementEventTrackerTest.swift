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

class PBMOpenMeasurementEventTrackerTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testEventsForWebViewSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = "{}"
        measurement.libraryManager = mockLibraryManager
        
        let webViewSession = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNotNil(webViewSession)
        XCTAssertNotNil(webViewSession?.eventTracker)
        
        let pbmTracker = webViewSession?.eventTracker as? PBMOpenMeasurementEventTracker
        XCTAssertNotNil(pbmTracker)
        XCTAssertNotNil(pbmTracker?.adEvents)
        
        XCTAssertNil(pbmTracker?.mediaEvents)
    }
    
    func testEventsForNativeVideoSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = "{}"
        measurement.libraryManager = mockLibraryManager
        
        let verificationParams = PBMVideoVerificationParameters()
        let resource = PBMVideoVerificationResource()
        resource.url = "openx.com"
        resource.vendorKey = "OpenX"
        resource.params = "no params"
        verificationParams.verificationResources.add(resource)
        
        let nativeVideoSession = measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams)
        
        XCTAssertNotNil(nativeVideoSession)
        XCTAssertNotNil(nativeVideoSession?.eventTracker)
        
        let pbmTracker = nativeVideoSession?.eventTracker as? PBMOpenMeasurementEventTracker
        XCTAssertNotNil(pbmTracker)
        XCTAssertNotNil(pbmTracker?.adEvents)
        XCTAssertNotNil(pbmTracker?.mediaEvents)
    }
    
    func testInvalidSession() {
        logToFile = .init()
        
        var pbmTracker = PBMOpenMeasurementEventTracker(session: OMIDPrebidorgAdSession())
        XCTAssertNotNil(pbmTracker)
        XCTAssertNotNil(pbmTracker.session)
        UtilitiesForTesting.checkLogContains("Open Measurement can't create ad events with error")
        
        pbmTracker = PBMOpenMeasurementEventTracker()
        XCTAssertNotNil(pbmTracker)
        XCTAssertNil(pbmTracker.session)
        
        logToFile = nil
        logToFile = .init()
        
        pbmTracker.trackEvent(PBMTrackingEvent.request)
        UtilitiesForTesting.checkLogContains("Measurement Session is missed")
    }
}

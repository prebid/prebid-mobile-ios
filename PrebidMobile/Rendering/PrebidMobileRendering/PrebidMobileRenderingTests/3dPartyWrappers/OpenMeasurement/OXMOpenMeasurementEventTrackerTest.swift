//
//  PBMOpenMeasurementEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class PBMOpenMeasurementEventTrackerTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testEventsForWebViewSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.jsLib = "{}"
        
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
        
        measurement.jsLib = "{}"
        
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

//
//  PBMOpenMeasurementWrapperTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

let ValidOMPartnerName = "Openx"
let InvalidOMPartnerName = ""

extension PBMOpenMeasurementWrapper {
    @objc var partnerName: String? {
        return ValidOMPartnerName
    }
}

class PBMOpenMeasurementWrapperErrorMock : PBMOpenMeasurementWrapper {
    override var partnerName: String? {
        return InvalidOMPartnerName
    }
}

class PBMOpenMeasurementWrapperTest: XCTestCase {
    
    func testInitialization() {
        let measurement = PBMOpenMeasurementWrapper()
        XCTAssertNil(measurement.jsLib)
    }
    
    func testLocalJSLibWrongBundle() {
        let loadJSLibExpectation = expectation(description: "load js lib expectation")
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.initializeJSLib(with: Bundle.main, completion: {
            XCTAssertNil(measurement.jsLib)
            loadJSLibExpectation.fulfill();
        })
        
        waitForExpectations(timeout: 2)
    }
    
    func testLocalJSLib() {
        let loadJSLibExpectation = expectation(description: "load js lib expectation")
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.initializeJSLib(with: PBMFunctions.bundleForSDK(), completion: {
            XCTAssertNotNil(measurement.jsLib)
            loadJSLibExpectation.fulfill();
        })
        
        waitForExpectations(timeout: 2)
    }
    
    func testInjectJSLib() {
        let measurement = PBMOpenMeasurementWrapper()
        measurement.jsLib = "test JS";
        
        let html = "<html><\\html>"
        
        guard let htmlWithMeasurementJS = try? measurement.injectJSLib(html) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(htmlWithMeasurementJS.range(of: measurement.jsLib!))
    }
    
    func testInitWebViewSession() {
        let measurement = PBMOpenMeasurementWrapper()
        let session = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNotNil(session)
    }
    
    func testInitWebViewSessionWithoutCredentials() {
        let measurement = PBMOpenMeasurementWrapperErrorMock()
        let session = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNil(session)
    }
    
    func testInitNativeVideoSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        // No js lib - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:nil))
        
        measurement.jsLib = ""

        // Empty resources - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:nil))
        
        // Still empty resources - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:PBMVideoVerificationParameters()))

        let verificationParams = PBMVideoVerificationParameters()
        verificationParams.verificationResources.add(PBMVideoVerificationResource())

        // Still empty resources - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams))
        
        verificationParams.verificationResources.removeLastObject()
        let resource = PBMVideoVerificationResource()
        resource.url = "openx.com"
        resource.vendorKey = "OpenX"
        resource.params = "no params"
        verificationParams.verificationResources.add(resource)

        // Resources fine but js is empty - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams))

        measurement.jsLib = "{}"
        XCTAssertNotNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams))
    }
    
    func testInitNativeVideoSessionHappyPath() {
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.jsLib = "{}"
        
        let verificationParams = PBMVideoVerificationParameters()
        let resource = PBMVideoVerificationResource()
        resource.url = "openx.com"
        resource.vendorKey = "OpenX"
        resource.params = "no params"
        verificationParams.verificationResources.add(resource)
        
        let session = measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams)
        
        XCTAssertNotNil(session)
    }
    
    func testInitNativeVideoSessionWithoutCredentials() {
        let measurement = PBMOpenMeasurementWrapperErrorMock()
        
        measurement.jsLib = "{}"
        
        let verificationParams = PBMVideoVerificationParameters()
        let resource = PBMVideoVerificationResource()
        resource.url = "openx.com"
        resource.vendorKey = "OpenX"
        resource.params = "no params"
        verificationParams.verificationResources.add(resource)
        
        let session = measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams)

        XCTAssertNil(session)
    }
    
    func testInitEventTrackerForSessions() {
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
        
        let webViewSession = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNotNil(webViewSession)
        XCTAssertNotNil(webViewSession?.eventTracker)
    }
}

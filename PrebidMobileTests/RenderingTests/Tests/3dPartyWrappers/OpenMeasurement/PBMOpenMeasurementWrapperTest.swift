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
        XCTAssertNotNil(measurement.libraryManager)
    }
    
    func testLocalJSLib() {
        let measurement = PBMOpenMeasurementWrapper()
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = "{}"
        measurement.libraryManager = mockLibraryManager
        
        let script = measurement.fetchOMSDKScript()
        XCTAssertNotNil(script)
    }
    
    func testInjectJSLib() {
        let testScript = "test JS"
        let measurement = PBMOpenMeasurementWrapper()
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = testScript
        measurement.libraryManager = mockLibraryManager
        
        let html = "<html><\\html>"
        
        guard let htmlWithMeasurementJS = try? measurement.injectJSLib(html) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(htmlWithMeasurementJS.range(of: testScript))
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
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = "{}"
        measurement.libraryManager = mockLibraryManager
        
        // No js lib - fail
        XCTAssertNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:nil))
        
        mockLibraryManager.omsdkScript = ""
        
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
        
        mockLibraryManager.omsdkScript = "{}"
        XCTAssertNotNil(measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams))
    }
    
    func testInitNativeVideoSessionHappyPath() {
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
        
        let session = measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams)
        
        XCTAssertNotNil(session)
    }
    
    func testInitNativeVideoSessionWithoutCredentials() {
        let measurement = PBMOpenMeasurementWrapperErrorMock()
        
        let mockLibraryManager = MockPrebidJSLibraryManager()
        mockLibraryManager.omsdkScript = "{}"
        measurement.libraryManager = mockLibraryManager
        
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
        
        let webViewSession = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNotNil(webViewSession)
        XCTAssertNotNil(webViewSession?.eventTracker)
    }
}

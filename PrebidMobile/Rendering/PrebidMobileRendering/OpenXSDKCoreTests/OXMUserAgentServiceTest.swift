//
//  OXMUserAgentServiceTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMUserAgentServiceTest: XCTestCase {
    
    let sdkVersion = OXMFunctions.sdkVersion()
    var expectationUserAgentExecuted: XCTestExpectation?

    func testUserAgentService() {

        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        
        let userAgentService = OXMUserAgentService.singleton()
        
        // Waiting for JS userAgent execute asynchronously
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let userAgentString = userAgentService.getFullUserAgent()
            
            //Should start with a useragent from the Web View
            XCTAssert(userAgentString.OXMdoesMatch("^Mozilla"))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                XCTAssert(userAgentString.OXMdoesMatch("iPad"))
            } else if UIDevice.current.userInterfaceIdiom == .phone {
                XCTAssert(userAgentString.OXMdoesMatch("iPhone"))
            }
            
            XCTAssert(userAgentString.OXMdoesMatch("AppleWebKit"))
            
            //Should end with the SDK version
            XCTAssert(userAgentString.OXMdoesMatch(" OpenXSDK/\(self.sdkVersion)$"))
            
            self.expectationUserAgentExecuted?.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }

    func testInjectedSDKVersion() {
        let injectedSDKVersion = "x.y.z"
        OXMUserAgentService.singleton().sdkVersion = injectedSDKVersion
        let userAgentString = OXMUserAgentService.singleton().getFullUserAgent()

        let didFindInjectedSDKVersion = userAgentString.OXMdoesMatch("OpenXSDK/\(injectedSDKVersion)")
        XCTAssert(didFindInjectedSDKVersion)

        let didFindDefaultSDKVersion = userAgentString.OXMdoesMatch("OpenXSDK/\(sdkVersion)")
        XCTAssertFalse(didFindDefaultSDKVersion)
        
        OXMUserAgentService.singleton().sdkVersion = OXMFunctions.sdkVersion()
    }

    func testSingletonCreation() {
        let uaServiceSingleton = OXMUserAgentService.singleton()
        XCTAssertNotNil(uaServiceSingleton)
        XCTAssert(uaServiceSingleton === OXMUserAgentService.singleton())
    }

    func testSingletonSDKVersion() {
        let userAgentString = OXMUserAgentService.singleton().getFullUserAgent()
        let didFindDefaultSDKVersion = userAgentString.OXMdoesMatch("OpenXSDK/\(sdkVersion)")
        XCTAssert(didFindDefaultSDKVersion)
    }

    func testFromBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")

        DispatchQueue.global(qos: .background).async {
            let userAgentString = OXMUserAgentService.singleton().getFullUserAgent()
            let didFindDefaultSDKVersion = userAgentString.OXMdoesMatch("OpenXSDK/\(self.sdkVersion)")
            XCTAssert(didFindDefaultSDKVersion)
            
            expectationCheckThread.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSetUserAgentInBackgroundThread() {
        let service = OXMUserAgentService.singleton()
        
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        expectationCheckThread.expectedFulfillmentCount = 2
        let thread = OXMThread { isCalledFromMainThread in
            expectationCheckThread.fulfill()
        }
        
        DispatchQueue.global().async {
            service.setUserAgentInThread(thread)
        }

        waitForExpectations(timeout: 1)
    }
}

//
//  PBMUserAgentServiceTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMUserAgentServiceTest: XCTestCase {
    
    let sdkVersion = PBMFunctions.sdkVersion()
    var expectationUserAgentExecuted: XCTestExpectation?

    func testUserAgentService() {

        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        
        let userAgentService = PBMUserAgentService.singleton()
        
        // Waiting for JS userAgent execute asynchronously
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let userAgentString = userAgentService.getFullUserAgent()
            
            //Should start with a useragent from the Web View
            XCTAssert(userAgentString.PBMdoesMatch("^Mozilla"))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                XCTAssert(userAgentString.PBMdoesMatch("iPad"))
            } else if UIDevice.current.userInterfaceIdiom == .phone {
                XCTAssert(userAgentString.PBMdoesMatch("iPhone"))
            }
            
            XCTAssert(userAgentString.PBMdoesMatch("AppleWebKit"))
            
            //Should end with the SDK version
            XCTAssert(userAgentString.PBMdoesMatch(" PrebidMobileRendering/\(self.sdkVersion)$"))
            
            self.expectationUserAgentExecuted?.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }

    func testInjectedSDKVersion() {
        let injectedSDKVersion = "x.y.z"
        PBMUserAgentService.singleton().sdkVersion = injectedSDKVersion
        let userAgentString = PBMUserAgentService.singleton().getFullUserAgent()

        let didFindInjectedSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(injectedSDKVersion)")
        XCTAssert(didFindInjectedSDKVersion)

        let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(sdkVersion)")
        XCTAssertFalse(didFindDefaultSDKVersion)
        
        PBMUserAgentService.singleton().sdkVersion = PBMFunctions.sdkVersion()
    }

    func testSingletonCreation() {
        let uaServiceSingleton = PBMUserAgentService.singleton()
        XCTAssertNotNil(uaServiceSingleton)
        XCTAssert(uaServiceSingleton === PBMUserAgentService.singleton())
    }

    func testSingletonSDKVersion() {
        let userAgentString = PBMUserAgentService.singleton().getFullUserAgent()
        let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(sdkVersion)")
        XCTAssert(didFindDefaultSDKVersion)
    }

    func testFromBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")

        DispatchQueue.global(qos: .background).async {
            let userAgentString = PBMUserAgentService.singleton().getFullUserAgent()
            let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(self.sdkVersion)")
            XCTAssert(didFindDefaultSDKVersion)
            
            expectationCheckThread.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSetUserAgentInBackgroundThread() {
        let service = PBMUserAgentService.singleton()
        
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        expectationCheckThread.expectedFulfillmentCount = 2
        let thread = PBMThread { isCalledFromMainThread in
            expectationCheckThread.fulfill()
        }
        
        DispatchQueue.global().async {
            service.setUserAgentInThread(thread)
        }

        waitForExpectations(timeout: 1)
    }
}

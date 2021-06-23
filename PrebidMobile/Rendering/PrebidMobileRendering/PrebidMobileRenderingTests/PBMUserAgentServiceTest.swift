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

class PBMUserAgentServiceTest: XCTestCase {
    
    let sdkVersion = PBMFunctions.sdkVersion()
    var expectationUserAgentExecuted: XCTestExpectation?

    func testUserAgentService() {

        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        
        let userAgentService = PBMUserAgentService.shared
        
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
        PBMUserAgentService.shared.sdkVersion = injectedSDKVersion
        let userAgentString = PBMUserAgentService.shared.getFullUserAgent()

        let didFindInjectedSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(injectedSDKVersion)")
        XCTAssert(didFindInjectedSDKVersion)

        let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(sdkVersion)")
        XCTAssertFalse(didFindDefaultSDKVersion)
        
        PBMUserAgentService.shared.sdkVersion = PBMFunctions.sdkVersion()
    }

    func testSharedCreation() {
        let uaServiceShared = PBMUserAgentService.shared
        XCTAssertNotNil(uaServiceShared)
        XCTAssert(uaServiceShared === PBMUserAgentService.shared)
    }

    func testSharedSDKVersion() {
        let userAgentString = PBMUserAgentService.shared.getFullUserAgent()
        let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(sdkVersion)")
        XCTAssert(didFindDefaultSDKVersion)
    }

    func testFromBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")

        DispatchQueue.global(qos: .background).async {
            let userAgentString = PBMUserAgentService.shared.getFullUserAgent()
            let didFindDefaultSDKVersion = userAgentString.PBMdoesMatch("PrebidMobileRendering/\(self.sdkVersion)")
            XCTAssert(didFindDefaultSDKVersion)
            
            expectationCheckThread.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSetUserAgentInBackgroundThread() {
        let service = PBMUserAgentService.shared
        
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

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
        let userAgentString = userAgentService.getFullUserAgent()
        
        //Should start with a useragent from the Web View
        XCTAssert(userAgentString.PBMdoesMatch("^Mozilla"))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCTAssert(userAgentString.PBMdoesMatch("iPad"))
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            XCTAssert(userAgentString.PBMdoesMatch("iPhone"))
        }
        
        XCTAssert(userAgentString.PBMdoesMatch("AppleWebKit"))
        
        self.expectationUserAgentExecuted?.fulfill()
        
        waitForExpectations(timeout: 5)
    }
    
    func testInjectedSDKVersion() {
        let injectedSDKVersion = "x.y.z"
        PBMUserAgentService.shared.sdkVersion = injectedSDKVersion
        let userAgentSDKVersion = PBMUserAgentService.shared.sdkVersion
        
        let didFindInjectedSDKVersion = userAgentSDKVersion?.PBMdoesMatch(injectedSDKVersion)
        XCTAssert((didFindInjectedSDKVersion != nil))
        
        PBMUserAgentService.shared.sdkVersion = PBMFunctions.sdkVersion()
    }
    
    func testSharedCreation() {
        let uaServiceShared = PBMUserAgentService.shared
        XCTAssertNotNil(uaServiceShared)
        XCTAssert(uaServiceShared === PBMUserAgentService.shared)
    }
    
    func testSharedSDKVersion() {
        XCTAssert(sdkVersion == PBMUserAgentService.shared.sdkVersion)
    }
    
    func testFromBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        
        DispatchQueue.global(qos: .background).async {
            XCTAssert(self.sdkVersion == PBMUserAgentService.shared.sdkVersion)
            
            expectationCheckThread.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSetUserAgentInBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")         
        expectationCheckThread.expectedFulfillmentCount = 3
        
        let thread = PBMThread { isCalledFromMainThread in
            expectationCheckThread.fulfill()
        }
        
        class MockUserAgentService: PBMUserAgentService {
            
            var thread: PBMThread
            
            init(thread: PBMThread) {
                self.thread = thread
                super.init()
            }
            
            override func setUserAgent() {
                super.setUserAgentInThread(thread)
            }
        }
        
        let service = MockUserAgentService(thread: thread)
        
        DispatchQueue.global().async {
            service.setUserAgentInThread(thread)
        }
        
        waitForExpectations(timeout: 1)
    }
}

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

private class MockUserAgentPersistence: UserAgentPersistence {
    var userAgent: String?
    required init(osVersion: String? = nil) {}
}

class UserAgentServiceTest: XCTestCase {
    
    var expectationUserAgentExecuted: XCTestExpectation?
    
    var service: UserAgentService {
        UserAgentService(store: MockUserAgentPersistence())
    }
    
    func testUserAgentService() {
        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        
        let userAgentService = service
        
        userAgentService.fetchUserAgent { [weak self] userAgentString in
            XCTAssert(userAgentService.userAgent == userAgentString)
            
            XCTAssert(userAgentString.PBMdoesMatch("^Mozilla"))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                XCTAssert(userAgentString.PBMdoesMatch("iPad"))
            } else if UIDevice.current.userInterfaceIdiom == .phone {
                XCTAssert(userAgentString.PBMdoesMatch("iPhone"))
            }
            
            XCTAssert(userAgentString.PBMdoesMatch("AppleWebKit"))
            
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func testSharedCreation() {
        let uaServiceShared = UserAgentService.shared
        XCTAssertNotNil(uaServiceShared)
        XCTAssert(uaServiceShared === UserAgentService.shared)
    }
    
    func testFromBackgroundThread() {
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        
        DispatchQueue.global(qos: .background).async {
            print(self.service.userAgent)
            expectationCheckThread.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testMultipleCalls() {
        let userAgentService = service

        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        expectationUserAgentExecuted?.expectedFulfillmentCount = 3
        
        userAgentService.fetchUserAgent { [weak self] _ in
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        userAgentService.fetchUserAgent { [weak self] _ in
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        userAgentService.fetchUserAgent { [weak self] _  in
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssert(userAgentService.userAgent.isEmpty == false)
    }
    
    func testPersistence() {
        let userAgentService = UserAgentService()

        expectationUserAgentExecuted = expectation(description: "expectationUserAgentExecuted")
        expectationUserAgentExecuted?.expectedFulfillmentCount = 2
        
        userAgentService.fetchUserAgent { [weak self] _ in
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        userAgentService.fetchUserAgent { [weak self] _ in
            self?.expectationUserAgentExecuted?.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssert(userAgentService.userAgent.isEmpty == false)
    }
}

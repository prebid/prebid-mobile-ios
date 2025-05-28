/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

class UserAgentDefaultsTest: XCTestCase {
    
    var userAgentDefaults: UserAgentDefaults!
    
    override func setUp() {
        super.setUp()
        // Initialize UserAgentDefaults before each test
        userAgentDefaults = UserAgentDefaults()
    }
    
    override func tearDown() {
        // Reset UserDefaults and UserAgentDefaults after each test
        userAgentDefaults.reset()
        userAgentDefaults = nil
        super.tearDown()
    }
    
    func testUserAgentPersistence() {
        // Test setting and getting the user agent
        let testUserAgent = "TestUserAgentString"
        userAgentDefaults.userAgent = testUserAgent
        
        XCTAssertEqual(userAgentDefaults.userAgent, testUserAgent, "User agent should be correctly set and retrieved.")
    }
    
    func testUserAgentInitializationWithCurrentOSVersion() {
        // Test that the user agent is correctly initialized with the current OS version
        let testUserAgent = "TestUserAgentString"
        userAgentDefaults.userAgent = testUserAgent
        
        let newUserAgentDefaults = UserAgentDefaults()
        XCTAssertEqual(newUserAgentDefaults.userAgent, testUserAgent, "User agent should be correctly retrieved with current OS version.")
    }
    
    func testUserAgentReset() {
        // Test resetting the user agent
        let testUserAgent = "TestUserAgentString"
        userAgentDefaults.userAgent = testUserAgent
        userAgentDefaults.reset()
        
        XCTAssertNil(userAgentDefaults.userAgent, "User agent should be nil after reset.")
    }
    
    func testUserAgentPersistenceWithDifferentOSVersion() {
        // Test user agent persistence with a different OS version
        let testUserAgent = "TestUserAgentString"
        let customOSVersion = "CustomOSVersion"
        
        let customUserAgentDefaults = UserAgentDefaults(osVersion: customOSVersion)
        customUserAgentDefaults.userAgent = testUserAgent
        
        XCTAssertEqual(customUserAgentDefaults.userAgent, testUserAgent, "User agent should be correctly set and retrieved for a custom OS version.")
        
        let newCustomUserAgentDefaults = UserAgentDefaults(osVersion: customOSVersion)
        XCTAssertEqual(newCustomUserAgentDefaults.userAgent, testUserAgent, "User agent should be correctly retrieved for a custom OS version.")
    }
    
    func testEmptyUserAgent() {
        userAgentDefaults.userAgent = "TestUserAgentString"
        // Test setting an empty user agent string
        userAgentDefaults.userAgent = nil
        XCTAssertNil(userAgentDefaults.userAgent, "User agent should be nil when set to an empty string.")
    }
    
    func testContents() {
        // Test the contents property
        let testUserAgent = "TestUserAgentString"
        userAgentDefaults.userAgent = testUserAgent
        
        XCTAssertEqual(userAgentDefaults.contents?[UIDevice.current.systemVersion], testUserAgent, "Contents should include the user agent for the current OS version.")
    }
}

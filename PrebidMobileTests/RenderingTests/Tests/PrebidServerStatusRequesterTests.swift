/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class PrebidServerStatusRequesterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Prebid.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Prebid.reset()
    }
    
    func testURLValidation() {
        XCTAssertTrue("https://prebid-server-test-j.prebid.org/openrtb2/auction".isValidURL())
        XCTAssertTrue("http://www.google.com".isValidURL())
        XCTAssertTrue("http://stackoverflow.com".isValidURL())
        XCTAssertTrue("stackoverflow.com".isValidURL())
        XCTAssertTrue("http://127.0.0.1".isValidURL())
        XCTAssertTrue("http://127.0.0.1/status".isValidURL())
        
        XCTAssertFalse("123".isValidURL())
        XCTAssertFalse("/status".isValidURL())
    }
    
    func testStatusEndpoint_Default() {
        let testHost = "https://unique-prebid-server-host.org"
        try? Prebid.shared.setCustomPrebidServer(url: "\(testHost)/openrtb2/auction")
        let requester = PrebidServerStatusRequester()
        
        let expectedStatusEndpoint = "\(testHost)/status/"
        XCTAssertTrue(requester.serverEndpoint == expectedStatusEndpoint)
    }
    
    func testStatusEndpoint_Nil() {
        let requester = PrebidServerStatusRequester()
        XCTAssertNil(requester.serverEndpoint)
        
        requester.requestStatus { status, error in
            XCTAssert(status == .serverStatusWarning)
            XCTAssertNotNil(error)
        }
    }
    
    func testSetCustomStatusEndpoint_Success() {
        let url = "https://prebid-server-test-j.prebid.org/openrtb2/auction"
        let requester = PrebidServerStatusRequester()
        
        requester.setCustomStatusEndpoint(url)
        
        XCTAssert(requester.serverEndpoint == url)
    }
    
    func testSetCustomStatusEndpoint_Failure() {
        let url = "/status"
        let requester = PrebidServerStatusRequester()
        
        requester.setCustomStatusEndpoint(url)
        
        XCTAssert(requester.serverEndpoint != url)
    }
    
    func testRequestStatus_Success() {
        try? Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        
        let expectation = expectation(description: "Expected successful status response.")
        
        let requester = PrebidServerStatusRequester()
        
        requester.requestStatus { status, error in
            if case .succeeded = status {
                expectation.fulfill()
            }
            
            if let error = error {
                XCTFail("Failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
}

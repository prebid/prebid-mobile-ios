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

@testable @_spi(PBMInternal) import PrebidMobile

class PBMBidRequesterTest: XCTestCase {
    private var sdkConfiguration: Prebid!
    private let targeting = Targeting.shared
    
    override func setUp() {
        super.setUp()
        sdkConfiguration = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        sdkConfiguration.prebidServerAccountId = Prebid.devintAccountID
    }
    
    override func tearDown() {
        sdkConfiguration = nil
        super.tearDown()
    }
    
    func testBanner_300x250() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.someValidResponse)
        }])
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        requester.requestBids { (bidResponse, error) in
            exp.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_noRequest() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.prebidServerAccountId = " \t \t  "
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidAccountId() as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let accountID = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.invalidAccountIDResponse(accountID: accountID))
        }])
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.prebidServerAccountId = accountID
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidAccountId() as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_noRequest() {
        let adUnitConfig = AdUnitConfig(configId: " \t \t  ", size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidConfigId() as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.invalidConfigIdResponse(configId: configId))
        }])
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidConfigId() as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidSize() {
        let adUnitConfig = AdUnitConfig(configId: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: -300, height: 250))
        let connection = MockServerConnection()
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAdditionalSize() {
        let adUnitConfig = AdUnitConfig(configId: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: 300, height: 250))
        adUnitConfig.additionalSizes = [CGSize(width: -320, height: 50)]
        
        let connection = MockServerConnection()
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_requestInProgress() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                callback(PBMBidResponseTransformer.someValidResponse)
            }
        }])
        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)
        
        let exp_ok = expectation(description: "exp_ok")
        let exp_fail = expectation(description: "exp_fail")
        
        requester.requestBids { (bidResponse, error) in
            exp_ok.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp_fail.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }

    // MARK: - Regression Tests for Issue #1195

    /// Regression test for GitHub issue #1195 crash fix.
    /// Verifies that duplicate network callbacks (from redirects/retries) are handled safely
    /// with @synchronized and nil checking, preventing EXC_BAD_ACCESS at 0x10.
    func testDuplicateCallback_ShouldNotCrash() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))

        var callbackCount = 0
        let exp = expectation(description: "exp")
        exp.expectedFulfillmentCount = 1 // Should only be called once even with duplicate network callbacks

        // Mock connection that calls the callback TWICE to simulate the race condition
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            NSLog("[TEST] First callback invocation")
            callback(PBMBidResponseTransformer.someValidResponse)

            // Simulate duplicate callback after a small delay (like redirect or retry)
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.1) {
                NSLog("[TEST] Second callback invocation (DUPLICATE - should be handled safely)")
                callback(PBMBidResponseTransformer.someValidResponse)
            }
        }])

        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)

        requester.requestBids { (bidResponse, error) in
            callbackCount += 1
            NSLog("[TEST] Completion block called (count: \(callbackCount))")

            if callbackCount == 1 {
                // First call should succeed
                XCTAssertNotNil(bidResponse)
                XCTAssertNil(error)
                exp.fulfill()
            } else {
                // Second call should never happen with proper fix
                XCTFail("Completion block called \(callbackCount) times - should only be called once!")
            }
        }

        waitForExpectations(timeout: 2)

        // Give time for the duplicate callback to potentially execute
        Thread.sleep(forTimeInterval: 0.5)

        // Verify completion was only called once
        XCTAssertEqual(callbackCount, 1, "Completion should be called exactly once, but was called \(callbackCount) times")
    }

    /// Regression test for GitHub issue #1195 with concurrent callbacks.
    /// Verifies thread-safe handling when multiple threads invoke callbacks simultaneously.
    func testConcurrentDuplicateCallbacks_ShouldBeThreadSafe() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))

        var callbackCount = 0
        let callbackLock = NSLock()
        let exp = expectation(description: "exp")
        exp.expectedFulfillmentCount = 1

        // Mock connection that calls callback from multiple threads simultaneously
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            let response = PBMBidResponseTransformer.someValidResponse

            // Call from multiple threads at nearly the same time
            DispatchQueue.global(qos: .userInitiated).async {
                NSLog("[TEST] Thread 1 callback")
                callback(response)
            }

            DispatchQueue.global(qos: .background).async {
                NSLog("[TEST] Thread 2 callback (concurrent duplicate)")
                callback(response)
            }

            DispatchQueue.global(qos: .utility).async {
                NSLog("[TEST] Thread 3 callback (concurrent duplicate)")
                callback(response)
            }
        }])

        let requester = Factory.createBidRequester(connection: connection,
                                                   sdkConfiguration: sdkConfiguration,
                                                   targeting: targeting,
                                                   adUnitConfiguration: adUnitConfig)

        requester.requestBids { (bidResponse, error) in
            callbackLock.lock()
            callbackCount += 1
            let currentCount = callbackCount
            callbackLock.unlock()

            NSLog("[TEST] Completion block called (count: \(currentCount))")

            if currentCount == 1 {
                XCTAssertNotNil(bidResponse)
                XCTAssertNil(error)
                exp.fulfill()
            } else {
                XCTFail("Completion called \(currentCount) times - should only be called once!")
            }
        }

        waitForExpectations(timeout: 2)

        // Give time for concurrent callbacks to potentially execute
        Thread.sleep(forTimeInterval: 0.5)

        callbackLock.lock()
        let finalCount = callbackCount
        callbackLock.unlock()

        XCTAssertEqual(finalCount, 1, "Completion should be called exactly once even with concurrent callbacks, but was called \(finalCount) times")
    }
}

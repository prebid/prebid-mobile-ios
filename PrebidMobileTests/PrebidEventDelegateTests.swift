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

private typealias Callback = (Data?, Data?) -> Void

class PrebidEventDelegateTests: XCTestCase {
    
    // `Prebid.shared.eventDelegate` is process-global, and `PBMBidRequester` fires it too, so
    // an in-flight response from another test can reach this delegate. Tagging the payloads
    // per test instance lets the callback ignore foreign invocations instead of relaxing the
    // expectation with `assertForOverFulfill = false`, which would also mask a genuine
    // double-call from the code under test.
    private let tag = UUID().uuidString
    private lazy var mockRequestData = "req-\(tag)".data(using: .utf8)
    private lazy var mockResponseData = "res-\(tag)".data(using: .utf8)

    var delegate: PrebidEventDelegate?

    override func tearDown() {
        super.tearDown()

        Prebid.reset()
        delegate = nil
    }

    func test_eventDelegate_isCalled() {
        let exp = expectation(description: "Expect PrebidEventDelegate to be called")

        let expectedRequestData = mockRequestData
        let expectedResponseData = mockResponseData

        delegate = PrebidEventDelegateTestsMockDelegate(onRequestDidFinish: { requestData, responseData in
            guard requestData == expectedRequestData else { return } // another test's request
            XCTAssertEqual(responseData, expectedResponseData)
            XCTAssertFalse(Thread.isMainThread)
            exp.fulfill()
        })

        Prebid.shared.eventDelegate = delegate

        Prebid.shared.callEventDelegateAsync_prebidBidRequestDidFinishWith(requestData: expectedRequestData, responseData: expectedResponseData)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_callEventDelegateAsync_doesNothing_whenDelegateIsNil() {
        /// This test aims to ensure that there is no nullpointer exception if the delegate is unset
        /// and a call to `callEventDelegateAsync_prebidBidRequestDidFinishWith(_:,:_)` is made
        Prebid.shared.eventDelegate = nil
        Prebid.shared.callEventDelegateAsync_prebidBidRequestDidFinishWith(requestData: mockRequestData, responseData: mockResponseData)
    }
}

private class PrebidEventDelegateTestsMockDelegate: PrebidEventDelegate {
    private let onRequestDidFinish: Callback
    
    init(onRequestDidFinish: @escaping Callback) {
        self.onRequestDidFinish = onRequestDidFinish
    }

    func prebidBidRequestDidFinish(requestData: Data?, responseData: Data?) {
        onRequestDidFinish(requestData, responseData)
    }
}

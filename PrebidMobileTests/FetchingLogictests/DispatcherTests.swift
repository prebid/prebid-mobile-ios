/*   Copyright 2018-2019 Prebid.org, Inc.

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

class DispatcherTests: XCTestCase, DispatcherDelegate {

    var loadSuccesfulException: XCTestExpectation?
    var timeoutForRequest: TimeInterval = 0.0

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        timeoutForRequest = 10.0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        loadSuccesfulException = nil
    }

    func testDispatcherIsNotNil() {
        let dispatcher = Dispatcher(withDelegate: self, autoRefreshMillies: 0.0)
        XCTAssertNotNil(dispatcher)
        XCTAssertNil(dispatcher.timer)
    }

    func testStartDispatcherWithRefreshMiliseconds() {
        let dispatcher = Dispatcher(withDelegate: self, autoRefreshMillies: 10.0)
        dispatcher.start()
        XCTAssertNotNil(dispatcher.timer)
        XCTAssertEqual(dispatcher.timer?.timeInterval, TimeInterval(10.0/1000))
        loadSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testStopDispatcher() {
        let dispatcher = Dispatcher(withDelegate: self, autoRefreshMillies: 10.0)
        XCTAssertEqual(dispatcher.state, .notStarted)
        
        dispatcher.start()
        XCTAssertEqual(dispatcher.state, .running)
        XCTAssertNotNil(dispatcher.timer)
        XCTAssertTrue(dispatcher.timer!.isValid)
        
        dispatcher.stop()
        XCTAssertEqual(dispatcher.state, .stopped)
        XCTAssertNil(dispatcher.timer)
        XCTAssertNotNil(dispatcher.stoppingTime)
        XCTAssertNotNil(dispatcher.firingTime)
    }
    
    func testAutorefreshDispatcher() {
        let dispatcher = Dispatcher(withDelegate: self, autoRefreshMillies: 10.0)
        dispatcher.start()
        loadSuccesfulException = expectation(description: "\(#function)")
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        sleep(5)
        
        dispatcher.stop()
        XCTAssertNotNil(dispatcher.stoppingTime)
        XCTAssertNotNil(dispatcher.firingTime)
        
        let remainTime = dispatcher.stoppingTime?.timeIntervalSince(dispatcher.firingTime!)
        XCTAssertNotNil(remainTime)
        XCTAssertEqual(remainTime!, 5.0, accuracy: 0.5)
    }

    // MARK: - DispatcherDelegate method
    func refreshDemand() {
        loadSuccesfulException?.fulfill()
    }
}

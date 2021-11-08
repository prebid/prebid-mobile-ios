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

class PBMAutoRefreshManagerTest: XCTestCase {
    func testNoTimerAutoStart() {
        let callbackExpectation = expectation(description: "callback called")
        callbackExpectation.isInverted = true
        withExtendedLifetime(PBMAutoRefreshManager(prefetchTime: 0,
                                                   refreshDelay: { 5 },
                                                   mayRefreshNowBlock: { true },
                                                   refreshBlock: callbackExpectation.fulfill)) {
            waitForExpectations(timeout: 6)
        }
    }
    
    func testNoTimerAutoStartWithPrefetch() {
        let callbackExpectation = expectation(description: "callback called")
        callbackExpectation.isInverted = true
        withExtendedLifetime(PBMAutoRefreshManager(prefetchTime: 2,
                                                   refreshDelay: { 4 },
                                                   mayRefreshNowBlock: { true },
                                                   refreshBlock: callbackExpectation.fulfill)) {
            waitForExpectations(timeout: 7)
        }
    }
    
    func testInitialRequest() {
        let callbackExpectation = expectation(description: "callback called")
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0,
                                                       refreshDelay: { 5 },
                                                       mayRefreshNowBlock: { true },
                                                       refreshBlock: callbackExpectation.fulfill)
        let beforeSetup = Date()
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 6)
        let afterWait = Date()
        XCTAssertLessThanOrEqual(abs(afterWait.timeIntervalSince(beforeSetup) - 5), 0.25)
    }
    
    func testInitialRequestWithPrefetch() {
        let callbackExpectation = expectation(description: "callback called")
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 2,
                                                       refreshDelay: { 6 },
                                                       mayRefreshNowBlock: { true },
                                                       refreshBlock: callbackExpectation.fulfill)
        let beforeSetup = Date()
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 5)
        let afterWait = Date()
        XCTAssertLessThanOrEqual(abs(afterWait.timeIntervalSince(beforeSetup) - 4), 0.25)
    }
    
    func testStopTimer() {
        let callbackExpectation = expectation(description: "callback called")
        callbackExpectation.isInverted = true
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0,
                                                       refreshDelay: { 4 },
                                                       mayRefreshNowBlock: { true },
                                                       refreshBlock: callbackExpectation.fulfill)
        autoRefreshManager.setupRefreshTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            autoRefreshManager.cancelRefreshTimer()
        }
        waitForExpectations(timeout: 9)
    }
    
    func testNoRepeatedRequest() {
        let callbackExpectation = expectation(description: "callback called")
        let nextExpectation = NSMutableArray(object: callbackExpectation)
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0, refreshDelay: {3}, mayRefreshNowBlock: {true}) {
            (nextExpectation[0] as? XCTestExpectation)?.fulfill()
        }
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 4)
        let noCallbackExpectation = expectation(description: "callback not called")
        noCallbackExpectation.isInverted = true
        waitForExpectations(timeout: 5)
    }
    
    func testNoRepeatedRequestWithPrefetch() {
        let callbackExpectation = expectation(description: "callback called")
        let nextExpectation = NSMutableArray(object: callbackExpectation)
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 2, refreshDelay: {6}, mayRefreshNowBlock: {true}) {
            (nextExpectation[0] as? XCTestExpectation)?.fulfill()
        }
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 5)
        let noCallbackExpectation = expectation(description: "callback not called")
        noCallbackExpectation.isInverted = true
        waitForExpectations(timeout: 13)
    }
    
    func testNoRepeatedlyNotAllowedRequest() {
        let mayRefreshCalledExpectation = expectation(description: "mayRefresh called")
        mayRefreshCalledExpectation.expectedFulfillmentCount = 3
        let callbackExpectation = expectation(description: "callback called")
        callbackExpectation.isInverted = true
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0,
                                                       refreshDelay: { 3 },
                                                       mayRefreshNowBlock: {
            mayRefreshCalledExpectation.fulfill()
            return false
        },
                                                       refreshBlock: callbackExpectation.fulfill)
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 10)
    }
    
    func testNoRepeatedlyNotAllowedRequestWithPrefetch() {
        let mayRefreshCalledExpectation = expectation(description: "mayRefresh called")
        mayRefreshCalledExpectation.expectedFulfillmentCount = 3
        let callbackExpectation = expectation(description: "callback called")
        callbackExpectation.isInverted = true
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 2,
                                                       refreshDelay: { 6 },
                                                       mayRefreshNowBlock: {
            mayRefreshCalledExpectation.fulfill()
            return false
        },
                                                       refreshBlock: callbackExpectation.fulfill)
        autoRefreshManager.setupRefreshTimer()
        waitForExpectations(timeout: 13)
    }
    
    func testAllowRefreshOnSecondAtempt() {
        let mayRefreshCallCount = NSMutableArray(object: NSNumber(value: 0))
        let mayRefreshCalledExpectations = (0..<3).map { expectation(description: "mayRefresh called \($0)") }
        mayRefreshCalledExpectations[2].isInverted = true
        let callbackExpectation = expectation(description: "callback called")
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0,
                                                       refreshDelay: { 3 },
                                                       mayRefreshNowBlock: {
            let iterationIndex = (mayRefreshCallCount[0] as? NSNumber)?.intValue ?? 0
            mayRefreshCallCount[0] = NSNumber(value: iterationIndex + 1)
            mayRefreshCalledExpectations[iterationIndex].fulfill()
            return iterationIndex == 1
        },
                                                       refreshBlock: callbackExpectation.fulfill)
        autoRefreshManager.setupRefreshTimer()
        let controlledTimeout = expectation(description: "timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 11, execute: controlledTimeout.fulfill)
        waitForExpectations(timeout: 11)
    }
    
    func testAllowRefreshOnSecondAtemptWithPrefetch() {
        let mayRefreshCallCount = NSMutableArray(object: NSNumber(value: 0))
        let mayRefreshCalledExpectations = (0..<3).map { expectation(description: "mayRefresh called \($0)") }
        mayRefreshCalledExpectations[2].isInverted = true
        let callbackExpectation = expectation(description: "callback called")
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 2,
                                                       refreshDelay: { 6 },
                                                       mayRefreshNowBlock: {
            let iterationIndex = (mayRefreshCallCount[0] as? NSNumber)?.intValue ?? 0
            mayRefreshCallCount[0] = NSNumber(value: iterationIndex + 1)
            mayRefreshCalledExpectations[iterationIndex].fulfill()
            return iterationIndex == 1
        },
                                                       refreshBlock: callbackExpectation.fulfill)
        autoRefreshManager.setupRefreshTimer()
        let controlledTimeout = expectation(description: "timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 13, execute: controlledTimeout.fulfill)
        waitForExpectations(timeout: 14)
    }
    
    func testBlocksCallSequence() {
        _testBlocksCallSequence(prefetchTime: 0,
                                callChain: [
                                    .delay(value: 5),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: true),
                                    .delay(value: 3),
                                    .mayRefresh(value: false),
                                    .delay(value: 6),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: false),
                                ],
                                expectedRefreshTimes: [5, 14])
    }
    
    func testBlocksCallSequenceWithPrefetch2() {
        _testBlocksCallSequence(prefetchTime: 2,
                                callChain: [
                                    .delay(value: 5),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: true),
                                    .delay(value: 3),
                                    .mayRefresh(value: false),
                                    .delay(value: 6),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: false),
                                ],
                                expectedRefreshTimes: [3, 8])
    }
    
    func testBlocksCallSequenceWithPrefetch3() {
        _testBlocksCallSequence(prefetchTime: 3,
                                callChain: [
                                    .delay(value: 5),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: true),
                                    .delay(value: 3),
                                    .mayRefresh(value: false),
                                    .delay(value: 6),
                                    .mayRefresh(value: true),
                                    .refresh(setupAgain: false),
                                ],
                                expectedRefreshTimes: [2, 5],
                                extraTimeToFinish: 2)
    }
    
    func testPostponeWithSetupRefresh() {
        let refreshDelay = 3.0
        let postponseCount = 5
        let postponeTime = 2.0
        
        let noCallbackExpectation = expectation(description: "callback not called")
        noCallbackExpectation.isInverted = true
        let expectationToFulfill = NSMutableArray(object: noCallbackExpectation)
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: 0,
                                                       refreshDelay: { refreshDelay },
                                                       mayRefreshNowBlock: { true })
        {
            (expectationToFulfill[0] as? XCTestExpectation)?.fulfill()
        }
        for i in 0...postponseCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + postponeTime * TimeInterval(i),
                                          execute: autoRefreshManager.setupRefreshTimer)
        }
        let checkTimeout = (TimeInterval(postponseCount) + 1) * postponeTime
        let controlledTimeout = expectation(description: "timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + checkTimeout, execute: controlledTimeout.fulfill)
        waitForExpectations(timeout: checkTimeout + 1)
        let callbackExpectation = expectation(description: "callback called")
        expectationToFulfill[0] = callbackExpectation
        waitForExpectations(timeout: refreshDelay - postponeTime + 1)
    }
    
    private enum ExpectedCallResult {
        case delay(value: TimeInterval)
        case mayRefresh(value: Bool)
        case refresh(setupAgain: Bool)
    }
    
    private func _testBlocksCallSequence(prefetchTime: TimeInterval,
                                         callChain: [ExpectedCallResult],
                                         expectedRefreshTimes: [TimeInterval],
                                         extraTimeToFinish: TimeInterval = 1)
    {
        let nextCallIndex = NSMutableArray(object: NSNumber(value: 0))
        let evaluateIterationIndex: ()->Int = {
            let result = (nextCallIndex[0] as? NSNumber)?.intValue ?? 0
            nextCallIndex[0] = NSNumber(value: result + 1)
            return result
        }
        let autoRefreshManagers = NSMutableArray()
        let failIteration = {
            XCTFail("Call mismatch on iteration #\((nextCallIndex[0] as? NSNumber)?.intValue ?? 0)")
        }
        let refreshPoints = NSMutableArray()
        let autoRefreshManager = PBMAutoRefreshManager(prefetchTime: prefetchTime,
                                                       refreshDelay: {
            switch callChain[evaluateIterationIndex()] {
            case .delay(let delay): return delay
            default: failIteration(); return nil
            }
        },
                                                       mayRefreshNowBlock: {
            switch callChain[evaluateIterationIndex()] {
            case .mayRefresh(let result): return result
            default: failIteration(); return false
            }
        },
                                                       refreshBlock: {
            refreshPoints.add(Date())
            switch callChain[evaluateIterationIndex()] {
            case .refresh(let setupAgain):
                if setupAgain {
                    (autoRefreshManagers[0] as? PBMAutoRefreshManager)?
                        .setupRefreshTimer()
                }
            default:
                failIteration()
            }
        })
        autoRefreshManagers.add(autoRefreshManager)
        let timeout = extraTimeToFinish + callChain.reduce(0.0) {
            switch $1 {
            case .delay(let v):
                return $0 + v - prefetchTime
            default:
                return $0
            }
        }
        let controlledTimeout = expectation(description: "timeout")
        let startTime = Date()
        autoRefreshManager.setupRefreshTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: controlledTimeout.fulfill)
        waitForExpectations(timeout: timeout + 1)
        XCTAssertEqual(nextCallIndex[0] as? NSNumber, NSNumber(value: callChain.count))
        let refreshTimes = refreshPoints.compactMap { ($0 as? Date)?.timeIntervalSince(startTime) }
        XCTAssertEqual(refreshTimes.count, expectedRefreshTimes.count)
        for i in 0..<min(refreshTimes.count, expectedRefreshTimes.count) {
            XCTAssertLessThanOrEqual(abs(refreshTimes[i] - expectedRefreshTimes[i]), extraTimeToFinish)
        }
    }
}

extension PBMAutoRefreshManager {
    convenience init(prefetchTime: TimeInterval,
                     refreshDelay: @escaping () -> TimeInterval?,
                     mayRefreshNowBlock: @escaping () -> Bool,
                     refreshBlock: @escaping () -> ()) {
        self.init(prefetchTime: prefetchTime,
                  locking:nil,
                  lockProvider:nil,
                  refreshDelay: { refreshDelay().map(NSNumber.init) },
                  mayRefreshNowBlock: mayRefreshNowBlock,
                  refreshBlock: refreshBlock)
    }
}

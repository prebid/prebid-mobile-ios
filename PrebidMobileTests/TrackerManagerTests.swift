/*   Copyright 2019-2020 Prebid.org, Inc.

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

private final class MockTrackerRetryTimerScheduler {
    private(set) var timers = [Timer]()
    var didScheduleTimer: (() -> Void)?

    func scheduleRetryTimer(
        withTimeInterval timeInterval: TimeInterval,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = Timer(timeInterval: timeInterval, repeats: true, block: block)
        timers.append(timer)
        didScheduleTimer?()
        return timer
    }
}

// Creates each tracker's expiration timer unscheduled. Firing it stands for the hour passing on the main run loop.
private final class MockTrackerExpirationTimerScheduler {
    private(set) var timers = [Timer]()
    private(set) var intervals = [TimeInterval]()

    func scheduleExpirationTimer(
        withTimeInterval timeInterval: TimeInterval,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = Timer(timeInterval: timeInterval, repeats: false, block: block)
        timers.append(timer)
        intervals.append(timeInterval)
        return timer
    }

    func fire(_ index: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard timers.indices.contains(index) else {
            return XCTFail("No expiration timer \(index); \(timers.count) scheduled", file: file, line: line)
        }
        timers[index].fire()
    }
}

private final class MockTrackerNetworkRequester {
    private(set) var requests = [URLRequest]()
    var error: Error?
    var errorsByURL = [String: Error]()
    var completionQueue: DispatchQueue?
    // When true, requests stay in flight until `completeHeldRequests(with:)`.
    var holdsCompletions = false
    private var heldCompletions = [(Error?) -> Void]()

    func execute(_ request: URLRequest, completion: @escaping (Error?) -> Void) {
        requests.append(request)
        let requestError = request.url
            .flatMap { errorsByURL[$0.absoluteString] } ?? error

        if holdsCompletions {
            heldCompletions.append(completion)
        } else if let completionQueue = completionQueue {
            completionQueue.async {
                completion(requestError)
            }
        } else {
            completion(requestError)
        }
    }

    func completeHeldRequests(with error: Error?) {
        let completions = heldCompletions
        heldCompletions.removeAll()
        completions.forEach { $0(error) }
    }
}

private enum TrackerManagerTestError: Error {
    case connectionFailed
}

class TrackerManagerTests: XCTestCase {

    func testMultipleQueuedTrackersScheduleOnlyOneRetryTimer() {
        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { false }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [
                "https://tracker.example/1",
                "https://tracker.example/2",
                "https://tracker.example/3"
            ],
            completion: nil
        )

        XCTAssertEqual(timerScheduler.timers.count, 1)
        XCTAssertTrue(timerScheduler.timers[0].isValid)
        XCTAssertTrue(networkRequester.requests.isEmpty)
    }

    func testRetryTimerInvalidatesItselfAndRetriesEveryQueuedTracker() {
        var networkIsReachable = false
        var firstTrackerResults = [Bool]()
        var secondTrackerResults = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { firstTrackerResults.append($0) }

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/2"]
        ) { secondTrackerResults.append($0) }

        XCTAssertEqual(timerScheduler.timers.count, 1)

        networkIsReachable = true
        let retryTimer = timerScheduler.timers[0]
        retryTimer.fire()
        retryTimer.fire()

        XCTAssertFalse(retryTimer.isValid)
        XCTAssertEqual(networkRequester.requests.compactMap { $0.url?.absoluteString }, [
            "https://tracker.example/1",
            "https://tracker.example/2"
        ])
        XCTAssertEqual(firstTrackerResults, [true])
        XCTAssertEqual(secondTrackerResults, [true])
    }

    func testMultipleFailedRetriesScheduleOnlyOneReplacementTimer() {
        var networkIsReachable = false

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.error = TrackerManagerTestError.connectionFailed

        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [
                "https://tracker.example/1",
                "https://tracker.example/2"
            ],
            completion: nil
        )

        networkIsReachable = true
        let firstRetryTimer = timerScheduler.timers[0]
        firstRetryTimer.fire()

        XCTAssertFalse(firstRetryTimer.isValid)
        XCTAssertEqual(networkRequester.requests.count, 2)
        XCTAssertEqual(timerScheduler.timers.count, 2)
        XCTAssertTrue(timerScheduler.timers[1].isValid)
    }

    func testReachableTrackersFireWithoutSchedulingRetryTimer() {
        var results = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { true }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [
                "https://tracker.example/1",
                "https://tracker.example/2"
            ]
        ) { results.append($0) }

        XCTAssertEqual(networkRequester.requests.count, 2)
        XCTAssertEqual(results, [true, true])
        XCTAssertTrue(timerScheduler.timers.isEmpty)
    }

    func testBackgroundNetworkFailureSchedulesRetryTimerOnMainThread() {
        let timerScheduled = expectation(description: "Retry timer scheduled")
        let timerScheduler = MockTrackerRetryTimerScheduler()
        timerScheduler.didScheduleTimer = {
            XCTAssertTrue(Thread.isMainThread)
            timerScheduled.fulfill()
        }

        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.error = TrackerManagerTestError.connectionFailed
        networkRequester.completionQueue = DispatchQueue.global(qos: .userInitiated)

        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { true }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"],
            completion: nil
        )

        wait(for: [timerScheduled], timeout: 1)
        XCTAssertEqual(timerScheduler.timers.count, 1)
    }

    func testBackgroundNetworkSuccessCallsCompletionOnMainThread() {
        let trackerCompleted = expectation(description: "Tracker completed")
        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.completionQueue = DispatchQueue.global(qos: .userInitiated)

        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { true }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertTrue(result)
            trackerCompleted.fulfill()
        }

        wait(for: [trackerCompleted], timeout: 1)
        XCTAssertTrue(timerScheduler.timers.isEmpty)
    }

    func testMaximumRetriesCompleteEachTrackerWithItsOwnResult() {
        let failedURL = "https://tracker.example/failure"
        let successfulURL = "https://tracker.example/success"
        var networkIsReachable = false
        var failedTrackerResults = [Bool]()
        var successfulTrackerResults = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.errorsByURL[failedURL] = TrackerManagerTestError.connectionFailed

        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [failedURL]
        ) {
            XCTAssertTrue(Thread.isMainThread)
            failedTrackerResults.append($0)
        }

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [successfulURL]
        ) {
            XCTAssertTrue(Thread.isMainThread)
            successfulTrackerResults.append($0)
        }

        networkIsReachable = true
        for retryIndex in 0..<3 {
            XCTAssertEqual(timerScheduler.timers.count, retryIndex + 1)
            timerScheduler.timers[retryIndex].fire()
        }

        XCTAssertEqual(
            networkRequester.requests.compactMap { $0.url?.absoluteString },
            [failedURL, successfulURL, failedURL, failedURL]
        )
        XCTAssertEqual(failedTrackerResults, [false])
        XCTAssertEqual(successfulTrackerResults, [true])
        XCTAssertEqual(timerScheduler.timers.count, 3)
        XCTAssertTrue(timerScheduler.timers.allSatisfy { !$0.isValid })
    }

    func testInvalidURLCallsCompletionWithFailure() {
        var results = [Bool]()
        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { true }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [""]
        ) { results.append($0) }

        XCTAssertEqual(results, [false])
        XCTAssertTrue(networkRequester.requests.isEmpty)
        XCTAssertTrue(timerScheduler.timers.isEmpty)
    }

    func testInvalidQueuedURLCallsCompletionWithFailure() {
        var networkIsReachable = false
        var results = [Bool]()
        let timerScheduler = MockTrackerRetryTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [""]
        ) { results.append($0) }

        networkIsReachable = true
        let retryTimer = timerScheduler.timers[0]
        retryTimer.fire()

        XCTAssertEqual(results, [false])
        XCTAssertFalse(retryTimer.isValid)
        XCTAssertTrue(networkRequester.requests.isEmpty)
    }

    func testExpiredTrackerCompletesWithFailureAndStopsRetryTimerWhileOffline() {
        var results = [Bool]()
        var laterResults = [Bool]()
        var networkIsReachable = false

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let expirationScheduler = MockTrackerExpirationTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            expirationScheduler: expirationScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { results.append($0) }

        expirationScheduler.fire(0)

        let retryTimer = timerScheduler.timers[0]
        retryTimer.fire()

        XCTAssertEqual(results, [false])
        XCTAssertFalse(retryTimer.isValid)
        XCTAssertTrue(networkRequester.requests.isEmpty)

        // The expired tracker left the queue: the next retry sends only a tracker queued later.
        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/2"]
        ) { laterResults.append($0) }
        networkIsReachable = true
        guard timerScheduler.timers.count == 2 else {
            return XCTFail("Expected a new retry timer for the later tracker, got \(timerScheduler.timers.count) timers")
        }
        timerScheduler.timers[1].fire()

        XCTAssertEqual(networkRequester.requests.compactMap { $0.url?.absoluteString }, ["https://tracker.example/2"])
        XCTAssertEqual(results, [false])
        XCTAssertEqual(laterResults, [true])
    }

    func testExpiredTrackerIsRemovedWhileRemainingTrackerKeepsRetryTimerAlive() {
        let expiredURL = "https://tracker.example/expired"
        let pendingURL = "https://tracker.example/pending"
        var networkIsReachable = false
        var expiredTrackerResults = [Bool]()
        var pendingTrackerResults = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let expirationScheduler = MockTrackerExpirationTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            expirationScheduler: expirationScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [expiredURL]
        ) { expiredTrackerResults.append($0) }

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: [pendingURL]
        ) { pendingTrackerResults.append($0) }

        // Each tracker has its own timer; only the first one's hour has passed.
        XCTAssertEqual(expirationScheduler.timers.count, 2)
        expirationScheduler.fire(0)

        let retryTimer = timerScheduler.timers[0]
        retryTimer.fire()

        XCTAssertEqual(expiredTrackerResults, [false])
        XCTAssertTrue(pendingTrackerResults.isEmpty)
        XCTAssertTrue(retryTimer.isValid)
        XCTAssertTrue(networkRequester.requests.isEmpty)

        networkIsReachable = true
        retryTimer.fire()

        XCTAssertEqual(networkRequester.requests.compactMap { $0.url?.absoluteString }, [pendingURL])
        XCTAssertEqual(expiredTrackerResults, [false])
        XCTAssertEqual(pendingTrackerResults, [true])
        XCTAssertFalse(retryTimer.isValid)
        XCTAssertEqual(timerScheduler.timers.count, 1)
    }

    func testTrackerExpiresWhenItsOneHourTimerFires() {
        var results = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let expirationScheduler = MockTrackerExpirationTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            expirationScheduler: expirationScheduler,
            isNetworkReachable: { false }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { results.append($0) }
        XCTAssertEqual(expirationScheduler.intervals, [3600], "One one-hour expiration timer for the queued tracker")
        let retryTimer = timerScheduler.timers[0]

        // Until the expiration timer fires (just before the hour), the tracker stays queued.
        retryTimer.fire()

        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(retryTimer.isValid)

        // The timer fires at the hour, and the next scan completes the tracker with failure.
        expirationScheduler.fire(0)
        retryTimer.fire()

        XCTAssertEqual(results, [false])
        XCTAssertFalse(retryTimer.isValid)
        XCTAssertTrue(networkRequester.requests.isEmpty)
    }

    func testFailedRetryKeepsTheOriginalExpirationTimer() {
        var networkIsReachable = false
        var results = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let expirationScheduler = MockTrackerExpirationTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.error = TrackerManagerTestError.connectionFailed
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            expirationScheduler: expirationScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { results.append($0) }

        // The first retry fails and queues the tracker again, with the timer it got when it was first queued.
        networkIsReachable = true
        timerScheduler.timers[0].fire()

        XCTAssertEqual(networkRequester.requests.count, 1)
        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(expirationScheduler.timers.count, 1, "A requeued tracker gets no new expiration timer")
        guard timerScheduler.timers.count == 2 else {
            return XCTFail("Expected a retry timer for the requeued tracker, got \(timerScheduler.timers.count) timers")
        }

        // That timer fires an hour after the tracker was first queued; the next scan drops the tracker.
        expirationScheduler.fire(0)
        timerScheduler.timers[1].fire()

        XCTAssertEqual(networkRequester.requests.count, 1, "An expired tracker is not sent again")
        XCTAssertEqual(results, [false])
        XCTAssertFalse(timerScheduler.timers[1].isValid)
    }

    func testTrackerThatExpiresWhileItsRetryIsInFlightIsNotQueuedAgain() {
        var networkIsReachable = false
        var results = [Bool]()

        let timerScheduler = MockTrackerRetryTimerScheduler()
        let expirationScheduler = MockTrackerExpirationTimerScheduler()
        let networkRequester = MockTrackerNetworkRequester()
        networkRequester.holdsCompletions = true
        let trackerManager = makeTrackerManager(
            networkRequester: networkRequester,
            timerScheduler: timerScheduler,
            expirationScheduler: expirationScheduler,
            isNetworkReachable: { networkIsReachable }
        )

        trackerManager.fireTrackerURLArray(
            arrayWithURLs: ["https://tracker.example/1"]
        ) { results.append($0) }

        // The retry starts before the hour has passed...
        networkIsReachable = true
        timerScheduler.timers[0].fire()
        XCTAssertEqual(networkRequester.requests.count, 1)

        // ...and fails after it.
        expirationScheduler.fire(0)
        networkRequester.completeHeldRequests(with: TrackerManagerTestError.connectionFailed)

        XCTAssertEqual(results, [false])
        XCTAssertEqual(timerScheduler.timers.count, 1, "The expired tracker is not queued for another retry")
        XCTAssertFalse(timerScheduler.timers[0].isValid)
    }

    private func makeTrackerManager(
        networkRequester: MockTrackerNetworkRequester,
        timerScheduler: MockTrackerRetryTimerScheduler,
        expirationScheduler: MockTrackerExpirationTimerScheduler = MockTrackerExpirationTimerScheduler(),
        isNetworkReachable: @escaping () -> Bool
    ) -> TrackerManager {
        TrackerManager.makeForTesting(
            executeNetworkRequest: networkRequester.execute,
            scheduleRetryTimer: timerScheduler.scheduleRetryTimer,
            scheduleExpirationTimer: expirationScheduler.scheduleExpirationTimer,
            isNetworkReachable: isNetworkReachable
        )
    }
}

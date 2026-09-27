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

import UIKit

class TrackerManager: NSObject {
    
    //MARK: Properties
    private struct PendingTracker {
        let trackerInfo: TrackerInfo
        let completion: OnComplete
    }

    private var trackerArray = [PendingTracker]()
    private var trackerRetryTimer : Timer?
    typealias  OnComplete = ((Bool) -> Void)?
    typealias NetworkRequestExecutor = (URLRequest, @escaping (Error?) -> Void) -> Void
    typealias RetryTimerScheduler = (TimeInterval, @escaping (Timer) -> Void) -> Timer

    private let executeNetworkRequest: NetworkRequestExecutor
    private let scheduleRetryTimer: RetryTimerScheduler
    private let isNetworkReachable: () -> Bool

    private static let trackerManagerRetryInterval : TimeInterval = 300
    private static let trackerManagerMaximumNumberOfRetries = 3
    
    /**
     * The class is created as a singleton object & used
     */
    @objc
    static let shared = TrackerManager()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        executeNetworkRequest = { request, completion in
            URLSession.shared.dataTask(with: request) { _, _, error in
                completion(error)
            }.resume()
        }
        scheduleRetryTimer = { timeInterval, block in
            Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: true,
                block: block
            )
        }
        isNetworkReachable = { Reachability.shared.isNetworkReachable }
        super.init()
    }

    #if DEBUG
    private init(
        executeNetworkRequest: @escaping NetworkRequestExecutor,
        scheduleRetryTimer: @escaping RetryTimerScheduler,
        isNetworkReachable: @escaping () -> Bool
    ) {
        self.executeNetworkRequest = executeNetworkRequest
        self.scheduleRetryTimer = scheduleRetryTimer
        self.isNetworkReachable = isNetworkReachable
        super.init()
    }

    /// Creates a tracker manager with deterministic dependencies for unit tests.
    /// Production code must use `TrackerManager.shared`.
    static func makeForTesting(
        executeNetworkRequest: @escaping NetworkRequestExecutor,
        scheduleRetryTimer: @escaping RetryTimerScheduler,
        isNetworkReachable: @escaping () -> Bool
    ) -> TrackerManager {
        TrackerManager(
            executeNetworkRequest: executeNetworkRequest,
            scheduleRetryTimer: scheduleRetryTimer,
            isNetworkReachable: isNetworkReachable
        )
    }
    #endif
    
    deinit {
        trackerRetryTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Public Methods
    func fireTrackerURLArray(arrayWithURLs: [String], completion: OnComplete){
        if arrayWithURLs.count == 0{
            complete(completion, with: false)
            return
        }
        
        if !isNetworkReachable() {
            Log.debug("Internet IS UNREACHABLE - queing trackers for firing later: \(arrayWithURLs)")
            arrayWithURLs.forEach { URL in
                queueTrackerURLForRetry(URL: URL, completion: completion)
            }
            return
        }
        
        Log.debug("Internet is reachable - FIRING TRACKERS: \(arrayWithURLs)")
        arrayWithURLs.forEach { urlString in
            if let url = urlString.encodedURL(with: .urlQueryAllowed) {
                let request = URLRequest(url: url)
                executeNetworkRequest(request) { [weak self] error in
                    guard error == nil else {
                        Log.debug("Internet REACHABILITY ERROR - queing tracker for firing later: \(urlString)")
                        guard let strongSelf = self else {
                            Log.debug("FAILED TO ACQUIRE strongSelf for fireTrackerURLArray")
                            return
                        }
                        strongSelf.queueTrackerURLForRetry(URL: urlString, completion: completion)
                        return
                    }
                    self?.complete(completion, with: true)
                }
            } else {
                complete(completion, with: false)
            }
        }
    }

    private func queueTrackerURLForRetry(URL: String, completion: OnComplete){
        performOnMain { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let pendingTracker = PendingTracker(
                trackerInfo: TrackerInfo(URL: URL),
                completion: completion
            )
            strongSelf.queueTrackerInfoForRetry(pendingTracker)
        }
    }
    
    private func queueTrackerInfoForRetry(_ pendingTracker: PendingTracker) {
        trackerArray.append(pendingTracker)
        scheduleRetryTimerIfNecessary()
    }
    
    private func scheduleRetryTimerIfNecessary() {
        // Use one retry timer for all queued URLs. Do not create another one while it is still active.
        guard trackerRetryTimer?.isValid != true else {
            return
        }

        trackerRetryTimer = scheduleRetryTimer(TrackerManager.trackerManagerRetryInterval) { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                Log.debug("FAILED TO ACQUIRE strongSelf for trackerRetryTimer")
                return
            }

            strongSelf.retryTrackerFires(firingTimer: timer)
        }
    }
    
    private func retryTrackerFires(firingTimer: Timer) {
        let expiredTrackers = trackerArray.filter { $0.trackerInfo.expired }
        trackerArray.removeAll { $0.trackerInfo.expired }
        expiredTrackers.forEach { complete($0.completion, with: false) }

        guard !trackerArray.isEmpty else {
            invalidateRetryTimer(firingTimer)
            return
        }

        guard isNetworkReachable() else {
            return
        }

        Log.debug("Internet back online - Firing \(trackerArray.count) queued trackers")
        let trackerArrayCopy = trackerArray
        trackerArray.removeAll()
        invalidateRetryTimer(firingTimer)

        trackerArrayCopy.forEach { pendingTracker in
            let info = pendingTracker.trackerInfo
            guard let urlString = info.URL,
                  let url = urlString.encodedURL(with: .urlQueryAllowed) else {
                complete(pendingTracker.completion, with: false)
                return
            }

            let request = URLRequest(url: url)
            executeNetworkRequest(request) { [weak self] error in
                guard error == nil else {
                    Log.debug("CONNECTION ERROR - queing tracker for firing later: \(urlString)")
                    guard let strongSelf = self else {
                        Log.debug("FAILED TO ACQUIRE strongSelf for retryTrackerFiresWithBlock")
                        return
                    }
                    strongSelf.performOnMain {
                        info.numberOfTimesFired += 1
                        if (info.numberOfTimesFired < TrackerManager.trackerManagerMaximumNumberOfRetries) && !info.expired{
                            strongSelf.queueTrackerInfoForRetry(pendingTracker)
                        }else{
                            strongSelf.complete(pendingTracker.completion, with: false)
                        }
                    }
                    return
                }
                Log.debug("RETRY SUCCESSFUL for \(info)")
                self?.complete(pendingTracker.completion, with: true)
            }
        }
    }

    private func invalidateRetryTimer(_ firingTimer: Timer) {
        firingTimer.invalidate()
        if trackerRetryTimer === firingTimer {
            trackerRetryTimer = nil
        }
    }

    private func complete(_ completion: OnComplete, with result: Bool) {
        guard let completion = completion else {
            return
        }

        performOnMain {
            completion(result)
        }
    }

    private func performOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

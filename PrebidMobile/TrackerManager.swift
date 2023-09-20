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
    private var internetIsReachable = false
    private var reachability: Reachability!
    private var trackerArray = [TrackerInfo]()
    private var trackerRetryTimer : Timer?
    typealias  OnComplete = ((Bool) -> Void)?
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
        super.init()
        self.reachability = Reachability.shared
        self.internetIsReachable = self.reachability.isNetworkReachable
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Public Methods
    func fireTrackerURLArray(arrayWithURLs: [String], completion: OnComplete){
        if arrayWithURLs.count == 0{
            if let completion = completion {
                completion(false)
            }
            return
        }
        
        internetIsReachable = reachability.isNetworkReachable
        
        if !internetIsReachable {
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
                URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                    guard error == nil else {
                        Log.debug("Internet REACHABILITY ERROR - queing tracker for firing later: \(urlString)")
                        guard let strongSelf = self else {
                            Log.debug("FAILED TO ACQUIRE strongSelf for fireTrackerURLArray")
                            return
                        }
                        strongSelf.queueTrackerURLForRetry(URL: urlString, completion: completion)
                        return
                    }
                    if let completion = completion {
                        completion(true)
                    }
                }.resume()
            }
        }
    }
    
    private func queueTrackerURLForRetry(URL: String, completion: OnComplete){
        queueTrackerInfoForRetry(trackerInfo: TrackerInfo.init(URL: URL), completion: completion)
    }
    
    private func queueTrackerInfoForRetry(trackerInfo: TrackerInfo, completion: OnComplete){
        trackerArray.append(trackerInfo)
        scheduleRetryTimerIfNecessaryWithBlock(completion: completion)
    }
    
    private func scheduleRetryTimerIfNecessaryWithBlock(completion: OnComplete){
        trackerRetryTimer = Timer.scheduledTimer(withTimeInterval: TrackerManager.trackerManagerRetryInterval, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                Log.debug("FAILED TO ACQUIRE strongSelf for trackerRetryTimer")
                return
            }
            strongSelf.retryTrackerFiresWithBlock(completion: completion)
            
        })
    }
    
    private func retryTrackerFiresWithBlock(completion: OnComplete){
        
        var trackerArrayCopy: [TrackerInfo]?
        internetIsReachable = reachability.isNetworkReachable
        
        if internetIsReachable {
            Log.debug("Internet back online - Firing trackers \(trackerArray)")
            trackerArrayCopy = trackerArray
            trackerArray.removeAll()
            trackerRetryTimer?.invalidate()
        }
        
        if trackerArrayCopy?.count != 0  {
            trackerArrayCopy?.forEach({ info in
                if info.expired{
                    return
                }
                
                if let urlString = info.URL,
                   let url = urlString.encodedURL(with: .urlQueryAllowed)
                {
                    let request = URLRequest(url: url)
                    URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                        guard error == nil else {
                            Log.debug("CONNECTION ERROR - queing tracker for firing later: \(urlString)")
                            guard let strongSelf = self else {
                                Log.debug("FAILED TO ACQUIRE strongSelf for retryTrackerFiresWithBlock")
                                return
                            }
                            info.numberOfTimesFired += 1
                            if (info.numberOfTimesFired < TrackerManager.trackerManagerMaximumNumberOfRetries) && !info.expired{
                                strongSelf.queueTrackerInfoForRetry(trackerInfo: info, completion: completion)
                            }else{
                                if let completion = completion {
                                    completion(false)
                                }
                            }
                            return
                        }
                        Log.debug("RETRY SUCCESSFUL for \(info)")
                        if let completion = completion {
                            completion(true)
                        }
                    }.resume()
                }
            })
        }
    }
}

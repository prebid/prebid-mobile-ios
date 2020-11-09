//
//  TrackerManager.swift
//  PrebidMobile
//
//  Created by Akash.Verma on 06/11/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

import UIKit

class TrackerManager: NSObject {
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
    }
    
    private var trackerArray = [TrackerInfo]()
    private let internetReachability: Reachability = Reachability()!
    private var trackerRetryTimer : Timer?
    typealias  OnComplete = ((Bool) -> Void)?
    
    //MARK: Public Methods
    func fireTrackerURLArray(arrayWithURLs: [String], completion: OnComplete){
        if arrayWithURLs.count == 0{
            if let completion = completion {
                completion(false)
            }
            return
        }
        
        if !internetIsReachable() {
            Log.debug("Internet IS UNREACHABLE - queing trackers for firing later: \(arrayWithURLs)")
            arrayWithURLs.forEach { URL in
                queueTrackerURLForRetry(URL: URL, completion: completion)
            }
            return
        }
        
        Log.debug("Internet is reachable - FIRING TRACKERS: \(arrayWithURLs)")
        arrayWithURLs.forEach { urlString in
            if let url = URL(string: urlString)
            {
                let request = URLRequest(url: url)
                URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                    guard error == nil else {
                        Log.debug("Internet REACHABILITY ERROR - queing tracker for firing later: \(urlString)")
                        guard let strongSelf = self else {
                            Log.debug("FAILED TO ACQUIRE strongSelf.")
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
        let context = ["completion": completion]
        trackerRetryTimer = Timer.scheduledTimer(timeInterval: Constants.kANTrackerManagerRetryInterval, target: self, selector:#selector(fireTimer), userInfo: context, repeats:true)
    }
    
    @objc func fireTimer(timer: Timer) {
        guard let context = timer.userInfo as? [String: OnComplete], let completion = context["completion"] else { return }
        retryTrackerFiresWithBlock(completion: completion)
    }
    
    private func retryTrackerFiresWithBlock(completion: OnComplete){
        
        var trackerArrayCopy: [TrackerInfo]?
        if internetIsReachable() {
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
                if let urlString = info.URL, let url = URL(string: urlString)
                {
                    let request = URLRequest(url: url)
                    URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                        guard error == nil else {
                            Log.debug("CONNECTION ERROR - queing tracker for firing later: \(urlString)")
                            guard let strongSelf = self else {
                                Log.debug("FAILED TO ACQUIRE strongSelf.")
                                return
                            }
                            info.numberOfTimesFired += 1
                            if (info.numberOfTimesFired < Constants.kANTrackerManagerMaximumNumberOfRetries) && !info.expired{
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
    
    private func internetIsReachable() -> Bool{
        return internetReachability.isReachable
    }
    
}

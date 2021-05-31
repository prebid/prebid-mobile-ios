//
//  LocalResponseInfoCache.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class LocalResponseInfoCache {
    
    var cachedResponses: [String : PBMCachedResponseInfo] = [:]
    var scheduledTimerFactory: PBMScheduledTimerFactory
    var expirationInterval: TimeInterval = 0.0
    var cacheLock = NSObject()

    public required init(scheduledTimerFactory: @escaping PBMScheduledTimerFactory,
                  expirationInterval: TimeInterval) {

        cachedResponses = [:]
        self.scheduledTimerFactory = PBMWeakTimerTargetBox.scheduledTimerFactory(weakifiedTarget: scheduledTimerFactory)
        self.expirationInterval = expirationInterval
    }
    
    public required convenience init(expirationInterval: TimeInterval) {
        self.init(
            scheduledTimerFactory: Timer.pbmScheduledTimerFactory(),
            expirationInterval: expirationInterval)
    }
    
    // MARK: - Internal API
    
    public func store(_ responseInfo: DemandResponseInfo) -> String {
        let uuid = UUID()
        let localCacheID = "Prebid_\(uuid.uuidString)"
        
        objc_sync_enter(cacheLock)
            let timer = scheduleExpirationTimer(forID: localCacheID)
            let cachedResponse = PBMCachedResponseInfo(responseInfo: responseInfo,
                                                       expirationTimer: timer)
            cachedResponses[localCacheID] = cachedResponse
        objc_sync_exit(cacheLock)
        
        return localCacheID
    }

    public func getStoredResponseInfo(_ localCacheID: String) -> DemandResponseInfo? {
        return getAndRemoveCachedResponseInfo(localCacheID)
    }
    
    // MARK: - Private API
    
    func scheduleExpirationTimer(forID localCacheID: String?) -> PBMTimerInterface {
        return scheduledTimerFactory(expirationInterval,    // interval
                                     self,                  // target
                                     #selector(expireCachedResponse(_:)), // selector
                                     localCacheID,          // user info
                                     false)                 // repeats
    }

    @objc func expireCachedResponse(_ localCacheID: String) {
        let expiredResponse = getAndRemoveCachedResponseInfo(localCacheID)
        notifyResponseInfoExpired(expiredResponse)
    }
    
    func getAndRemoveCachedResponseInfo(_ localCacheID: String) -> DemandResponseInfo? {
        var cachedEntry: PBMCachedResponseInfo? = nil
        
        objc_sync_enter(cacheLock)
            cachedEntry = cachedResponses[localCacheID]
            cachedEntry?.expirationTimer.invalidate()
            cachedResponses.removeValue(forKey: localCacheID)
        objc_sync_exit(cacheLock)
        
        return cachedEntry?.responseInfo
    }
    
    func notifyResponseInfoExpired(_ expiredResponseInfo: DemandResponseInfo?) {
        // TODO: Implement
    }
}

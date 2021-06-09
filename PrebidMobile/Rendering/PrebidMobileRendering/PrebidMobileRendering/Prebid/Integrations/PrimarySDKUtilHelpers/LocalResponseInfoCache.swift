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

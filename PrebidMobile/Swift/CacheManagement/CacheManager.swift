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

@objc(PBMCacheManager)
@objcMembers
public class CacheManager: NSObject {
    
    public static let cacheManagerExpireInterval : TimeInterval = 300
    
    /**
     * The class is created as a singleton object & used
     */
    public static let shared = CacheManager()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        super.init()
    }

    private let lock = NSLock()
    internal var savedValuesDict = [String : String]()
    private(set) var delegates = [CacheExpiryDelegateWrapper]()
    
    public func save(content: String, expireInterval: TimeInterval = CacheManager.cacheManagerExpireInterval) -> String? {
        if content.isEmpty {
            return nil
        } else {
            lock.lock()
            defer {
                lock.unlock()
            }
            let cacheId = "Prebid_" + UUID().uuidString
            self.savedValuesDict[cacheId] = content
            DispatchQueue.main.asyncAfter(deadline: .now() + expireInterval, execute: {
                self.lock.lock()
                defer {
                    self.lock.unlock()
                }
                self.savedValuesDict.removeValue(forKey: cacheId)
                
                if let delegate = self.delegates.filter({ $0.id == cacheId }).first {
                    delegate.delegate?.cacheExpired()
                    self.delegates.removeAll { $0.id == cacheId }
                }
            })
            return cacheId
        }
    }
    
    public func isValid(cacheId: String) -> Bool {
        lock.withLock {
            return self.savedValuesDict.keys.contains(cacheId)
        }
    }
    
    public func get(cacheId: String) -> String? {
        lock.withLock {
            return self.savedValuesDict[cacheId]
        }
    }
    
    func setDelegate(delegate: CacheExpiryDelegateWrapper) {
        lock.withLock {
            delegates.append(delegate)
        }
    }
}

//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

public class PBMCustomModelObjects: NSObject {
    
    private static var lock: UnsafeMutablePointer<pthread_rwlock_t> = {
        let lock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        lock.initialize(to: pthread_rwlock_t())
        pthread_rwlock_init(lock, nil)
        
        return lock
    }()
    
    private static var _customTypes = [(baseType: PBMORTBAbstract.Type, customType: PBMORTBAbstract.Type)]()
    static func getCustomType<T: PBMORTBAbstract>(_ type: T.Type) -> T.Type {
        pthread_rwlock_rdlock(lock)
        defer { pthread_rwlock_unlock(lock) }
        
        return _customTypes.first { $0.baseType == type }?.customType as? T.Type ?? type
    }
    
    static func setCustomType<T: PBMORTBAbstract>(baseType: T.Type, customType: T.Type) {
        pthread_rwlock_wrlock(lock)
        defer { pthread_rwlock_unlock(lock) }
        
        _customTypes.removeAll { $0.baseType == baseType }
        if customType != baseType {
            _customTypes.append((baseType: baseType, customType: customType))
        }
    }
    
    static func instantiate<T: PBMORTBAbstract>(json: [String : Any]) -> T? {
        getCustomType(T.self).init(jsonDictionary: json)
    }
    
    public static func unregisterCustomType(_ type: PBMORTBAbstract.Type) {
        pthread_rwlock_wrlock(lock)
        defer { pthread_rwlock_unlock(lock) }
        
        _customTypes.removeAll { type == $0.baseType || type == $0.customType }
    }
    
    public static func registerCustomType(_ type: PBMORTBAdConfiguration.Type) {
        setCustomType(baseType: PBMORTBAdConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExt.Type) {
        setCustomType(baseType: PBMORTBBidExt.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExtPrebid.Type) {
        setCustomType(baseType: PBMORTBBidExtPrebid.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExtPrebidCache.Type) {
        setCustomType(baseType: PBMORTBBidExtPrebidCache.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExtPrebidCacheBids.Type) {
        setCustomType(baseType: PBMORTBBidExtPrebidCacheBids.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExtSkadn.Type) {
        setCustomType(baseType: PBMORTBBidExtSkadn.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidExtSkadnSKOverlay.Type) {
        setCustomType(baseType: PBMORTBBidExtSkadnSKOverlay.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidResponseExt.Type) {
        setCustomType(baseType: PBMORTBBidResponseExt.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBBidResponseExtPrebid.Type) {
        setCustomType(baseType: PBMORTBBidResponseExtPrebid.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBExtPrebidEvents.Type) {
        setCustomType(baseType: PBMORTBExtPrebidEvents.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBExtPrebidPassthrough.Type) {
        setCustomType(baseType: PBMORTBExtPrebidPassthrough.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedClose.Type) {
        setCustomType(baseType: PBMORTBRewardedClose.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedCompletion.Type) {
        setCustomType(baseType: PBMORTBRewardedCompletion.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedCompletionBanner.Type) {
        setCustomType(baseType: PBMORTBRewardedCompletionBanner.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedCompletionVideo.Type) {
        setCustomType(baseType: PBMORTBRewardedCompletionVideo.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedCompletionVideoEndcard.Type) {
        setCustomType(baseType: PBMORTBRewardedCompletionVideoEndcard.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedConfiguration.Type) {
        setCustomType(baseType: PBMORTBRewardedConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBRewardedReward.Type) {
        setCustomType(baseType: PBMORTBRewardedReward.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBSDKConfiguration.Type) {
        setCustomType(baseType: PBMORTBSDKConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: PBMORTBSkadnFidelity.Type) {
        setCustomType(baseType: PBMORTBSkadnFidelity.self, customType: type)
    }
}

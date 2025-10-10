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

public class CustomModelObjects: NSObject {
    
    private static var lock: UnsafeMutablePointer<pthread_rwlock_t> = {
        let lock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        lock.initialize(to: pthread_rwlock_t())
        pthread_rwlock_init(lock, nil)
        return lock
    }()
    
    private static func lockedRead<T>(_ execute: () throws -> T) rethrows -> T {
        pthread_rwlock_rdlock(lock)
        defer { pthread_rwlock_unlock(lock) }
        return try execute()
    }
    
    private static func lockedWrite<T>(_ execute: () throws -> T) rethrows -> T {
        pthread_rwlock_wrlock(lock)
        defer { pthread_rwlock_unlock(lock) }
        return try execute()
    }
    
    private static var _customTypes = [(baseType: PBMJsonDecodable.Type, customType: PBMJsonDecodable.Type)]()
    static func getCustomType<T: PBMJsonDecodable>(_ type: T.Type) -> T.Type {
        lockedRead {
            _customTypes.first { $0.baseType == type }?.customType as? T.Type ?? type
        }
    }
    
    static func setCustomType<T: PBMJsonDecodable>(baseType: T.Type, customType: T.Type) {
        lockedWrite {
            _customTypes.removeAll { $0.baseType == baseType }
            if customType != baseType {
                _customTypes.append((baseType: baseType, customType: customType))
            }
        }
    }
    
    static func instantiate<T: PBMJsonDecodable>(json: [String : Any]) -> T? {
        getCustomType(T.self).init(jsonDictionary: json)
    }
    
    public static func unregisterCustomType(_ type: PBMJsonDecodable.Type) {
        lockedWrite {
            _customTypes.removeAll { type == $0.baseType || type == $0.customType }
        }
    }
    
    public static func registerCustomType(_ type: ORTBAdConfiguration.Type) {
        setCustomType(baseType: ORTBAdConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBBidExtSkadn.Type) {
        setCustomType(baseType: ORTBBidExtSkadn.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBBidExtSkadnSKOverlay.Type) {
        setCustomType(baseType: ORTBBidExtSkadnSKOverlay.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBBidResponseExt.Type) {
        setCustomType(baseType: ORTBBidResponseExt.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBBidResponseExtPrebid.Type) {
        setCustomType(baseType: ORTBBidResponseExtPrebid.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBExtPrebidEvents.Type) {
        setCustomType(baseType: ORTBExtPrebidEvents.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBExtPrebidPassthrough.Type) {
        setCustomType(baseType: ORTBExtPrebidPassthrough.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedClose.Type) {
        setCustomType(baseType: ORTBRewardedClose.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedCompletion.Type) {
        setCustomType(baseType: ORTBRewardedCompletion.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedCompletionBanner.Type) {
        setCustomType(baseType: ORTBRewardedCompletionBanner.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedCompletionVideo.Type) {
        setCustomType(baseType: ORTBRewardedCompletionVideo.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedCompletionVideoEndcard.Type) {
        setCustomType(baseType: ORTBRewardedCompletionVideoEndcard.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedConfiguration.Type) {
        setCustomType(baseType: ORTBRewardedConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBRewardedReward.Type) {
        setCustomType(baseType: ORTBRewardedReward.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBSDKConfiguration.Type) {
        setCustomType(baseType: ORTBSDKConfiguration.self, customType: type)
    }
    
    public static func registerCustomType(_ type: ORTBSkadnFidelity.Type) {
        setCustomType(baseType: ORTBSkadnFidelity.self, customType: type)
    }
}

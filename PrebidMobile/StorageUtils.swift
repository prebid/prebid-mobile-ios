/*   Copyright 2018-2019 Prebid.org, Inc.

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

class StorageUtils {
    
    static let PB_ExternalUserIdsKey = "kPBExternalUserIds"
    static let PB_SharedIdKey = "kPBSharedId"
    
    //External User Ids
    static func getExternalUserIds() -> [ExternalUserId]? {
        guard let value: Data = getObjectFromUserDefaults(forKey: StorageUtils.PB_ExternalUserIdsKey) else {
            return nil
        }
        
        return try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ExternalUserId.self, NSArray.self, NSString.self, NSNumber.self, NSDictionary.self], from: value) as? [ExternalUserId]
    }
    
    static func setExternalUserIds(value: [ExternalUserId]?) {
        if let value = value {
            let encodeData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
            setUserDefaults(value: encodeData, forKey: StorageUtils.PB_ExternalUserIdsKey)
        }
    }
    
    // SharedId
    static var sharedId: String? {
        get {
            UserDefaults.standard.string(forKey: PB_SharedIdKey)
        }
        
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: PB_SharedIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: PB_SharedIdKey)
            }
        }
    }
    
    //MARK: - private zone
    private static func setUserDefaults(value: Any?, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    private static func getObjectFromUserDefaults<T>(forKey: String) -> T? {
        return UserDefaults.standard.object(forKey: forKey) as? T
    }
}

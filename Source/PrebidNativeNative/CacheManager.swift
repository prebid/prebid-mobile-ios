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

public class CacheManager: NSObject {
    
    /**
     * The class is created as a singleton object & used
     */
    @objc
    public static let shared = CacheManager()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        super.init()
    }
    
    private var savedValuesDict = [String : String]()
    
    public func save(content : String) -> String?{
        if content.isEmpty {
            return nil
        }else{
            let cacheId = "Prebid_" + UUID().uuidString
            self.savedValuesDict[cacheId] = content
            let context = ["cacheId": cacheId]
            Timer.scheduledTimer(timeInterval: 300, target: self, selector:#selector(removeSavedValues), userInfo: context, repeats:false)
            return cacheId
        }
    }
    
    public func isValid(cacheId : String) -> Bool{
        return self.savedValuesDict.keys.contains(cacheId)
    }
    
    public func get(cacheId : String) -> String?{
        return self.savedValuesDict.removeValue(forKey: cacheId)
    }

    @objc func removeSavedValues(timer: Timer) {
        guard let context = timer.userInfo as? [String: String], let cacheId = context["cacheId"] else { return }
        self.savedValuesDict.removeValue(forKey: cacheId)
        timer.invalidate()
    }

}

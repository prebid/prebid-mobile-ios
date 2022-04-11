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
import PrebidMobile
import AppLovinSDK

@objcMembers
public class MAXUtils: NSObject {
    
    static func isServerParameterInTargetingInfo(_ serverParametersDictionary: [String: String]?, _ targetingInfoDictionary: [String: String]?) -> Bool {
        
        guard let serverParametersDictionary = serverParametersDictionary, !serverParametersDictionary.isEmpty else {
            Log.warn("Server parameters dictionary is empty")
            return false
        }
        
        guard let targetingInfoDictionary = targetingInfoDictionary, !targetingInfoDictionary.isEmpty else {
            Log.warn("Targeting info dictionary is empty")
            return false
        }
        
        for parameter in serverParametersDictionary {
            if targetingInfoDictionary[parameter.key] != parameter.value {
                Log.warn("Server parameter \(parameter.key):\(parameter.value) is absent in targeting info")
                return false
            }
        }
        
        return true
    }
}

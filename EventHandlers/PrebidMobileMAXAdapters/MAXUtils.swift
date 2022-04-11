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
    
    static func isServerParameterInKeywordsDictionary(_ serverParametersDictionary: [String: String], _ keywordsDictionary: [String: String]) -> Bool {
        
        guard !serverParametersDictionary.isEmpty else {
            Log.warn("Empty server parameter.")
            return false
        }
        
        guard !keywordsDictionary.isEmpty else {
            Log.warn("Empty user keywords.")
            return false
        }
        
        for parameter in serverParametersDictionary {
            if keywordsDictionary[parameter.key] != parameter.value {
                Log.warn("Server parameter is absent in user keywords.")
                return false
            }
        }
        
        return true
    }
}

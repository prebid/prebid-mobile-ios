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

class UtilitiesForTesting {
    class func loadFileAsDataFromBundle(_ fileName:String) -> Data? {
        let bundlePath = Bundle.main.resourcePath!
        var url = URL(fileURLWithPath: bundlePath)
        url.appendPathComponent(fileName)
        
        let ret = try? Data(contentsOf: url)
        return ret
    }

    class func loadFileAsStringFromBundle(_ fileName:String) -> String? {
        guard let data = loadFileAsDataFromBundle(fileName) else {
            return nil
        }
        
        let ret = String(data: data, encoding: String.Encoding.utf8)
        return ret
    }
}


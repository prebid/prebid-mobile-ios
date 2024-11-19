/*   Copyright 2018-2024 Prebid.org, Inc.

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

@objc(PBMArbitraryORTBService) @objcMembers
public class ArbitraryORTBService: NSObject {
    
    private override init() {
        super.init()
    }
    
    public static func enrich(
        with impORTB: String?,
        globalORTB: String?,
        existingORTB: [String: Any]
    ) -> [String: Any] {
        
        var resultORTB = existingORTB
        
        if let impORTBDict = ArbitraryImpORTBHelper(ortb: impORTB).getValidatedORTBDict() {
            let existingImps = existingORTB["imp"] as? [[String: Any]] ?? []
            resultORTB["imp"] = existingImps.map { $0.deepMerging(with: impORTBDict) }
        }
        
        if let globalORTBDict = ArbitraryGlobalORTBHelper(ortb: globalORTB).getValidatedORTBDict() {
            resultORTB = resultORTB.deepMerging(with: globalORTBDict)
        }
        
        return resultORTB
    }
}

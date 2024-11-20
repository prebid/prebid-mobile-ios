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
            let existingImps = resultORTB["imp"] as? [[String: Any]]
            resultORTB["imp"] = existingImps?.map { $0.deepMerging(with: impORTBDict) } ?? [impORTBDict]
        }
        
        if var globalORTBDict = ArbitraryGlobalORTBHelper(ortb: globalORTB).getValidatedORTBDict() {
            let existingImpDict = resultORTB["imp"] as? [[String: Any]]
            resultORTB["imp"] = nil
            
            let incomingImpDict = globalORTBDict["imp"] as? [[String: Any]]
            globalORTBDict["imp"] = nil
            
            // All values except `imp` are merging
            resultORTB = resultORTB.deepMerging(with: globalORTBDict)
            
            // Append global imps to existing
            if let existingImpDict, let incomingImpDict {
                resultORTB["imp"] = existingImpDict + incomingImpDict
            } else {
                resultORTB["imp"] = existingImpDict ?? incomingImpDict
            }
        }
        
        return resultORTB
    }
}

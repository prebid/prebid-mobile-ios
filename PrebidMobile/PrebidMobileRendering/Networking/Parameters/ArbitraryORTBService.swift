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
    
    public static func merge(
        sdkORTB: [String: Any],
        impORTB: String?,
        globalORTB: String?
    ) -> [String: Any] {
        var resultORTB = sdkORTB
        var resultImp = resultORTB["imp"] as? [[String: Any]]
        
        if let impORTB,
           let impORTBDict = ArbitraryImpORTBHelper(ortb: impORTB).getValidatedORTBDict() {
            // Imp objects from imp configuration should be merged to existing imp objects.
            resultImp = resultImp?.map { $0.deepMerging(with: impORTBDict) } ?? [impORTBDict]
        }
        
        if let globalORTB,
           let globalORTBDict = ArbitraryGlobalORTBHelper(ortb: globalORTB).getValidatedORTBDict() {
            resultORTB = resultORTB.deepMerging(with: globalORTBDict)
            
            // Imp objects from global configuration should be appended to existing array.
            if let globalImps = globalORTBDict["imp"] as? [[String: Any]] {
                resultImp = (resultImp ?? []) + globalImps
            }
        }
        
        resultORTB["imp"] = resultImp
        
        return resultORTB
    }
}

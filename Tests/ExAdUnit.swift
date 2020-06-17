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
@testable import PrebidMobile

@objcMembers
public class ExAdUnit: NSObject {

    static var testScenario = ResultCode.prebidDemandFetchSuccess

    public static let shared: AdUnit = {
        let exAdUnit = ExAdUnit()
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250))
        
        exAdUnit.initialize()
        return adUnit
    }()
   
    private func initialize() {
        
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(adObject:completion:)), cls2: ExAdUnit.self, sel2: #selector(ExAdUnit.swizzledFetchDemand(adObject:completion:)))
        Swizzling.exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(completion:)), cls2: ExAdUnit.self, sel2: #selector(ExAdUnit.swizzledFetchDemand(completion:)))

    }
    
    @objc
    fileprivate func swizzledFetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        completion(ExAdUnit.testScenario)
    }
    
    @objc
    fileprivate func swizzledFetchDemand(completion: @escaping(_ result: ResultCode, _ kvResultDict: [String : String]?) -> Void) {
        completion(ExAdUnit.testScenario, ["key1" : "value1"])
    }

}

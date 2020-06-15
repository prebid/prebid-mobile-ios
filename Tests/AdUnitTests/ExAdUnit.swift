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

extension AdUnit {

    static var testScenario = ResultCode.prebidDemandFetchSuccess

    static let shared: AdUnit = {
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250))
        adUnit.initialize()
        return adUnit
    }()
   
    private func initialize() {
        
        exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(adObject:completion:)), cls2: AdUnit.self, sel2: #selector(AdUnit.swizzledFetchDemand(adObject:completion:)))
        exchangeInstance(cls1: AdUnit.self, sel1: #selector(AdUnit.fetchDemand(completion:)), cls2: AdUnit.self, sel2: #selector(AdUnit.swizzledFetchDemand(completion:)))

    }
    
    @objc
    fileprivate func swizzledFetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        completion(AdUnit.testScenario)
    }
    
    @objc
    fileprivate func swizzledFetchDemand(completion: @escaping(_ result: ResultCode, _ kvResultDict: [String : String]?) -> Void) {
        completion(AdUnit.testScenario, ["key1" : "value1"])
    }

}

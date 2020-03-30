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

   private static var _myComputedProperty: ResultCode = .prebidDemandFetchSuccess

    var testScenario: ResultCode {
        get {
            return AdUnit._myComputedProperty
        }
        set(newValue) {
            AdUnit._myComputedProperty = newValue
        }
    }

    func mock_fetchDemandSuccess(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {

        if (AdUnit._myComputedProperty == ResultCode.prebidDemandFetchSuccess) {
            completion(ResultCode.prebidDemandFetchSuccess)
        } else if (AdUnit._myComputedProperty == ResultCode.prebidDemandNoBids) {
            completion(ResultCode.prebidDemandNoBids)
        } else if (AdUnit._myComputedProperty == ResultCode.prebidDemandTimedOut) {
            completion(ResultCode.prebidDemandTimedOut)
        } else if (AdUnit._myComputedProperty == ResultCode.prebidNetworkError) {
            completion(ResultCode.prebidNetworkError)
        }
    }

    static let shared: AdUnit = {
        $0.initialize()
        return $0
    }(AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250)))

    //In Objective-C you'd perform the swizzling in load() , but this method is not permitted in Swift
    func initialize() {
        // Perform this one time only
        struct Inner {
            static let i: () = {
                let originalSelector = #selector(AdUnit.fetchDemand(adObject:completion:))
                let swizzledSelector = #selector(AdUnit.mock_fetchDemandSuccess(adObject:completion:))

                let originalMethod = class_getInstanceMethod(AdUnit.self, originalSelector)
                let swizzledMethod = class_getInstanceMethod(AdUnit.self, swizzledSelector)

                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }()
        }
        _ = Inner.i
    }

}

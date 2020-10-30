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

import Foundation

public class InStreamVideoAdUnit: VideoBaseAdUnit {
    
    public init(configId: String) {
        super.init(configId: configId, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    //TODO: dynamic is used by tests
    
    dynamic public func fetchInstreamDemandForAdObject(adUnitId:String, completion: @escaping(_ result: ResultCode, _ adServerURL:String?) -> Void) {
        if (prebidConfigId.isEmpty || (prebidConfigId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidConfigId, nil)
            return
        }
        if (Prebid.shared.prebidServerAccountId.isEmpty || (Prebid.shared.prebidServerAccountId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidAccountId, nil)
            return
        }

        didReceiveResponse = false
        timeOutSignalSent = false
        let manager: BidManager = BidManager(adUnit: self)

        manager.requestBidsForAdUnit { [self] (bidResponse, resultCode) in
            self.didReceiveResponse = true
            if (bidResponse != nil) {
                if (!self.timeOutSignalSent) {
                    let adServerURL = IMAUtils.shared.constructAdTagURLForIMAWithPrebidKeys(adUnitID: adUnitId, customKeywords: bidResponse!.customKeywords)
                    completion(resultCode,adServerURL)
                }

            } else {
                if (!self.timeOutSignalSent) {
                    completion(ResultCode.prebidDemandNoBids,nil)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Prebid.shared.timeoutMillisDynamic), execute: {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(ResultCode.prebidDemandTimedOut,nil)

            }
        })
    }

}

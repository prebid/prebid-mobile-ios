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

import UIKit
import PrebidMobile
import AppLovinSDK

@objcMembers
public class MAXMediationRewardedUtils: NSObject, PrebidMediationDelegate {
    
    public var rewardedAd: MARewardedAd
    
    private var configIdKey = ""
    private var extrasObjectKey = ""
    
    public init(rewardedAd: MARewardedAd) {
        self.rewardedAd = rewardedAd
        super.init()
    }
    
    public func setUpAdObject(configId: String, configIdKey: String,
                              targetingInfo: [String: String], extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        self.configIdKey = configIdKey
        self.extrasObjectKey = extrasObjectKey
        
        rewardedAd.setLocalExtraParameterForKey(configIdKey, value: configId)
        rewardedAd.setLocalExtraParameterForKey(extrasObjectKey, value: extrasObject)
        
        return true
    }
    
    public func cleanUpAdObject() {
        rewardedAd.setLocalExtraParameterForKey(configIdKey, value: nil)
        rewardedAd.setLocalExtraParameterForKey(extrasObjectKey, value: nil)
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
}

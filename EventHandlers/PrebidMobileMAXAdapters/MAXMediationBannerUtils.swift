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
public class MAXMediationBannerUtils: NSObject, PrebidMediationDelegate {
    
    public var adView: MAAdView
    public var viewControllerForModalPresentation: UIViewController
    
    public init(adView: MAAdView, viewControllerForModalPresentation: UIViewController) {
        self.adView = adView
        self.viewControllerForModalPresentation = viewControllerForModalPresentation
        super.init()
    }
    
    public func setUpAdObject(configId: String, configIdKey: String,
                              targetingInfo: [String: String], extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        
        adView.setLocalExtraParameterForKey(configIdKey, value: configId)
        adView.setLocalExtraParameterForKey(extrasObjectKey, value: extrasObject)
        adView.setLocalExtraParameterForKey(PBMMediationTargetingInfoKey, value: targetingInfo)
        adView.setLocalExtraParameterForKey(PBMVCForModalPresentationKey, value: viewControllerForModalPresentation)
        
        return true
    }
    
    public func cleanUpAdObject() {
        
    }
    
    public func getAdView() -> UIView? {
        return adView
    }
}

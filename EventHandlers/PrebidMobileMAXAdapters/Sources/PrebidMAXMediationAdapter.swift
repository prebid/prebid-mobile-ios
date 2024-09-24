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
import PrebidMobile
import AppLovinSDK

public let MAXCustomParametersKey = "custom_parameters"

@objc(PrebidMAXMediationAdapter)
public class PrebidMAXMediationAdapter: ALMediationAdapter {
    
    // MARK: - Banner
    
    public weak var bannerDelegate: MAAdViewAdapterDelegate?
    public var displayView: PBMDisplayView?
    
    // MARK: - Interstitial
    
    public weak var interstitialDelegate: MAInterstitialAdapterDelegate?
    public var interstitialController: InterstitialController?
    public var interstitialAdAvailable = false
    
    // MARK: - Rewarded
    
    public weak var rewardedDelegate: MARewardedAdapterDelegate?
    
    // MARK: - Native
    
    public weak var nativeDelegate: MANativeAdAdapterDelegate?
    
    public override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping (MAAdapterInitializationStatus, String?) -> Void) {
        // TODO: Add Prebid SDK initialization logic
        
        completionHandler(.initializedUnknown, nil)
    }
    
    public override var sdkVersion: String {
        return Prebid.shared.version
    }
    
    public override var adapterVersion: String {
        MAXConstants.PrebidMAXAdapterVersion
    }
    
    public override func destroy() {
        bannerDelegate = nil
        displayView = nil
        
        interstitialDelegate = nil
        interstitialController = nil
        
        rewardedDelegate = nil
        
        nativeDelegate = nil
        super.destroy()
    }
}

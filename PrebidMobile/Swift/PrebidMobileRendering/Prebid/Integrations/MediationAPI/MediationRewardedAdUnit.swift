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

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationRewardedAdUnit : MediationBaseInterstitialAdUnit {
    
    /// The ad formats for the rewarded ad unit.
    /// Use `[.banner]` for display rewarded ads, `[.video]` for rewarded video ads, or both for multiformat rewarded inventory.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    // - MARK: Public Methods
    
    /// Initializes a new instance of the `MediationRewardedAdUnit` with the specified configuration ID and mediation delegate.
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - mediationDelegate: The delegate for mediation-related tasks.
    public override init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        super.init(configId: configId, mediationDelegate: mediationDelegate)
        
        adUnitConfig.adConfiguration.isRewarded = true
        adUnitConfig.adFormats = [.video]
    }
    
    /// Initializes a new rewarded mediation ad unit with the specified ad formats.
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - mediationDelegate: The delegate for mediation-related tasks.
    ///   - adFormats: The rewarded ad formats to request. Use `[.banner]` for display rewarded ads, `[.video]` for rewarded video ads, or both for multiformat rewarded inventory.
    public convenience init(configId: String, mediationDelegate: PrebidMediationDelegate, adFormats: Set<AdFormat>) {
        self.init(configId: configId, mediationDelegate: mediationDelegate)
        self.adFormats = adFormats
    }
}

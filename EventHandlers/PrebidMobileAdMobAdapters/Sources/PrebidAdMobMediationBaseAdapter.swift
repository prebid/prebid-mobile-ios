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
import GoogleMobileAds

public class PrebidAdMobMediationBaseAdapter: NSObject, GADMediationAdapter {
    
    public static func adapterVersion() -> GADVersionNumber {
        let adapterVersionComponents = AdMobConstants.PrebidAdMobRewardedAdapterVersion.components(separatedBy: ".").map( { Int($0) ?? 0})
        
        return adapterVersionComponents.count == 3 ? GADVersionNumber(majorVersion: adapterVersionComponents[0],
                                                                      minorVersion: adapterVersionComponents[1],
                                                                      patchVersion: adapterVersionComponents[2]): GADVersionNumber()
    }
    
    public static func adSDKVersion() -> GADVersionNumber {
        let sdkVersionComponents = Prebid.shared.version.components(separatedBy: ".").map( { Int($0) ?? 0})
        
        return sdkVersionComponents.count == 3 ? GADVersionNumber(majorVersion: sdkVersionComponents[0],
                                                                  minorVersion: sdkVersionComponents[1],
                                                                  patchVersion: sdkVersionComponents[2]): GADVersionNumber()
    }
    
    public static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return GADCustomEventExtras.self
    }
        
    // Added for tests
    static func latestTestedGMAVersion() -> GADVersionNumber {
        return GADVersionNumber(majorVersion: 11, minorVersion: 13, patchVersion: 0)
    }
    
    required public override init() {
        super.init()
    }
    
    public static func setUpWith(
        _ configuration: GADMediationServerConfiguration,
        completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock
    ) {
        // TODO: Add Prebid SDK initialization logic
    }
}

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

public class PrebidAdMobMediationBaseAdapter: NSObject, GoogleMobileAds.MediationAdapter {
    
    public static func adapterVersion() -> GoogleMobileAds.VersionNumber {
        let adapterVersionComponents = AdMobConstants
            .PrebidAdMobRewardedAdapterVersion
            .components(separatedBy: ".")
            .map( { Int($0) ?? 0})
        
        return adapterVersionComponents.count == 3 ? GoogleMobileAds.VersionNumber(
            majorVersion: adapterVersionComponents[0],
            minorVersion: adapterVersionComponents[1],
            patchVersion: adapterVersionComponents[2]
        ) : GoogleMobileAds.VersionNumber()
    }
    
    public static func adSDKVersion() -> GoogleMobileAds.VersionNumber {
        let sdkVersionComponents = Prebid
            .shared
            .version
            .components(separatedBy: ".")
            .map( { Int($0) ?? 0})
        
        return sdkVersionComponents.count == 3 ? GoogleMobileAds.VersionNumber(
            majorVersion: sdkVersionComponents[0],
            minorVersion: sdkVersionComponents[1],
            patchVersion: sdkVersionComponents[2]
        ) : GoogleMobileAds.VersionNumber()
    }
    
    public static func networkExtrasClass() -> GoogleMobileAds.AdNetworkExtras.Type? {
        GoogleMobileAds.CustomEventExtras.self
    }
        
    // Added for tests
    static func latestTestedGMAVersion() -> GoogleMobileAds.VersionNumber {
        GoogleMobileAds.VersionNumber(
            majorVersion: 12,
            minorVersion: 9,
            patchVersion: 0
        )
    }
    
    required public override init() {
        super.init()
    }
    
    public static func setUp(
        with configuration: GoogleMobileAds.MediationServerConfiguration,
        completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock
    ) {
        // TODO: Add Prebid SDK initialization logic
    }
}

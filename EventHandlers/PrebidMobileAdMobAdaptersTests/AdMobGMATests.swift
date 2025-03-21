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

import XCTest
import GoogleMobileAds
import PrebidMobile
@testable import PrebidMobileAdMobAdapters

final class AdMobGMATests: XCTestCase {
    
    func testGMAVersion() {
        let latestTestedGMAVersion = PrebidAdMobMediationBaseAdapter.latestTestedGMAVersion()
        let currentGMAVersion = MobileAds.shared.versionNumber
        
        if MobileAds.shared.isSDKVersionAtLeast(
            major: latestTestedGMAVersion.majorVersion,
            minor: latestTestedGMAVersion.minorVersion,
            patch: latestTestedGMAVersion.patchVersion
        ) {
            
            if currentGMAVersion.majorVersion != latestTestedGMAVersion.majorVersion ||
                currentGMAVersion.minorVersion != latestTestedGMAVersion.minorVersion ||
                currentGMAVersion.patchVersion != latestTestedGMAVersion.patchVersion {
                
                XCTFail("The current version of AdMob Adapters is not validated with the latest version of GMA SDK.")
            }
            
        } else {
            Log.info("Current GMA SDK version is lower than latest tested.")
        }
    }
}

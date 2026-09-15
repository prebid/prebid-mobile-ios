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

@testable import PrebidMobile

class MediationRewardedAdUnitTest: XCTestCase {
    
    let mediationDelegate: PrebidMediationDelegate = MockMediationUtils(adObject: MockAdObject())
    
    func testDefaultSettings() {
        let adUnit = MediationRewardedAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate)
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.adConfiguration.isInterstitialAd)
        XCTAssertTrue(adUnitConfig.adConfiguration.isRewarded)
        PBMAssertEq(adUnitConfig.adPosition, .fullScreen)
        XCTAssertTrue(adUnitConfig.adFormats.contains(.video))
    }
    
    func testSetAdFormats() {
        let adUnit = MediationRewardedAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate)
        
        adUnit.adFormats = [.banner]
        
        XCTAssertEqual(adUnit.adFormats, [.banner])
        XCTAssertEqual(adUnit.adUnitConfig.adConfiguration.adFormats, [.banner])
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isRewarded)
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isInterstitialAd)
    }
    
    func testAdFormatsInitializer() {
        let adUnit = MediationRewardedAdUnit(
            configId: "prebidConfigId",
            mediationDelegate: mediationDelegate,
            adFormats: [.banner]
        )
        
        XCTAssertEqual(adUnit.adFormats, [.banner])
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isRewarded)
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isInterstitialAd)
    }
    
    func testMultiformatRewarded() {
        let adUnit = MediationRewardedAdUnit(
            configId: "prebidConfigId",
            mediationDelegate: mediationDelegate,
            adFormats: [.banner, .video]
        )
        
        XCTAssertEqual(adUnit.adFormats, [.banner, .video])
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.adFormats.contains(.banner))
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.adFormats.contains(.video))
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isRewarded)
    }
    
    func testBannerAndVideoParametersAccessibleAfterFormatChange() {
        let adUnit = MediationRewardedAdUnit(configId: "prebidConfigId", mediationDelegate: mediationDelegate)
        
        adUnit.adFormats = [.banner]
        adUnit.bannerParameters.api = [Signals.Api.MRAID_1]
        adUnit.videoParameters.maxDuration = 30
        
        XCTAssertEqual(adUnit.bannerParameters.api, [Signals.Api.MRAID_1])
        XCTAssertEqual(adUnit.videoParameters.maxDuration, 30)
    }
}

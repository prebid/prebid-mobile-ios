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
@testable import PrebidMobileGAMEventHandlers

class GADRewardedAdWrapperTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADFullScreenContentDelegate {
        func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        }
    }
    
    private class DummyMetadataDelegate: NSObject, GADAdMetadataDelegate {
        func adMetadataDidChange(_ ad: GADAdMetadataProvider) {
            
        }
        
    }
    
    func testProperties() {        
        let propTests: [BasePropTest<GADRewardedAdWrapper>] = [
            RefProxyPropTest(keyPath: \.adMetadataDelegate, value: DummyMetadataDelegate()),
        ]
        
        guard let rewardedAd = GADRewardedAdWrapper(adUnitID: "/21808260008/prebid_oxb_rewarded_video_test") else {
            XCTFail()
            return
        }
        
        XCTAssertNil(rewardedAd.adMetadata)
        XCTAssertNil(rewardedAd.reward)
        
        for nextTest in propTests {
            nextTest.run(object: rewardedAd)
        }
    }
}

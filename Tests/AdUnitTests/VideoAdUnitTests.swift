/*   Copyright 2018-2019 Prebid.org, Inc.

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

class VideoAdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVideoAdUnitCreation() {
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2), type: .inBanner)
        XCTAssertEqual(1, adUnit.adSizes.count)
        XCTAssertEqual(Constants.configID1, adUnit.prebidConfigId)
        XCTAssertNil(adUnit.dispatcher)
        XCTAssertEqual(.inBanner, adUnit.type)
    }
    
    func testVideoParametersCreation() {
        
        //given
        let videoAdUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2), type: .inBanner)
        let videoInterstitialAdUnit = VideoInterstitialAdUnit(configId: Constants.configID1)
        let rewardedVideoAdUnit = RewardedVideoAdUnit(configId: Constants.configID1)
        
        let videoBaseAdUnitArr = [videoAdUnit, videoInterstitialAdUnit, rewardedVideoAdUnit]
        
        for videoBaseAdUnit in videoBaseAdUnitArr {
            checkVideoParametersHelper(videoBaseAdUnit: videoBaseAdUnit)
        }
        
    }
    
    func checkVideoParametersHelper(videoBaseAdUnit: VideoBaseAdUnit) {
        
        let parameters = VideoAdUnit.Parameters()
        parameters.api = [Api.VPAID_1, Api.VPAID_2]
        parameters.maxBitrate = 1500
        parameters.minBitrate = 300
        parameters.maxDuration = 30
        parameters.minDuration = 5
        parameters.mimes = ["video/x-flv", "video/mp4"]
        parameters.playbackMethod = [PlaybackMethod.AutoPlaySoundOn, PlaybackMethod.ClickToPlay]
        parameters.protocols = [Protocols.VAST_2_0, Protocols.VAST_3_0]
        parameters.startDelay = StartDelay.PreRoll
        
        videoBaseAdUnit.parameters = parameters;
        
        //when
        let testedVideoParameters = videoBaseAdUnit.parameters;
        
        //then
        guard let videoParameters = testedVideoParameters,
            let api = videoParameters.api,
            let maxBitrate = videoParameters.maxBitrate,
            let minBitrate = videoParameters.minBitrate,
            let maxDuration = videoParameters.maxDuration,
            let minDuration = videoParameters.minDuration,
            let mimes = videoParameters.mimes,
            let playbackMethod = videoParameters.playbackMethod,
            let protocols = videoParameters.protocols,
            let startDelay = videoParameters.startDelay else {
                XCTFail("parsing fail")
                return
        }
        
        XCTAssertEqual(2, api.count)
        XCTAssert(api.contains(1) && api.contains(2))
        XCTAssertEqual(1500, maxBitrate)
        XCTAssertEqual(300, minBitrate)
        XCTAssertEqual(30, maxDuration)
        XCTAssertEqual(5, minDuration)
        XCTAssertEqual(2, mimes.count)
        XCTAssert(mimes.contains("video/x-flv") && mimes.contains("video/mp4"))
        XCTAssertEqual(2, playbackMethod.count)
        XCTAssert(playbackMethod.contains(1) && playbackMethod.contains(3))
        XCTAssertEqual(2, protocols.count)
        XCTAssert(protocols.contains(2) && protocols.contains(3))
        XCTAssertEqual(0, startDelay)
    }
}

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

class AdUnitSuccessorTests: XCTestCase {
    
    let configId = Constants.configID1
    
    override func tearDown() {
        super.tearDown()
        
        Prebid.shared.useExternalClickthroughBrowser = false
    }
    
    // MARK: - BannerAdUnit
    
    func testBannerAdUnitCreation() {
        //when
        let adUnit = BannerAdUnit(configId: configId, size: CGSize(width: Constants.width2, height: Constants.height2))
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    func testBannerAdUnitAddSize() {
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1))
        adUnit.addAdditionalSize(sizes: [CGSize(width: Constants.width2, height: Constants.height2)])
        XCTAssertEqual(2, adUnit.adSizes.count)
    }
    
    func testBannerParametersCreation() {
        //given
        let bannerAdUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let interstitialAdUnit = InterstitialAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45")
        
        let bannerBasedAdUnits: [BannerBasedAdUnitProtocol] = [bannerAdUnit, interstitialAdUnit]
        bannerBasedAdUnits.forEach { checkBannerParametersHelper($0) }
    }
    
    // MARK: - InterstitialAdUnit
    
    func testInterstitialAdUnitCreation() {
        //when
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isInterstitialAd)
        XCTAssertTrue(adUnit.adUnitConfig.adPosition == .fullScreen)
        XCTAssertTrue(adUnit.adUnitConfig.adFormats == [.banner])
    }
    
    func testInterstitialAdUnitAdSize() {
        //when
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        
        //then
        XCTAssertTrue(adUnit.adUnitConfig.adSize == CGSize.zero)
    }
    
    func testInterstitialAdUnitConvenienceCreation() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        XCTAssertTrue(adUnit.adUnitConfig.minSizePerc?.cgSizeValue.width == 50 && adUnit.adUnitConfig.minSizePerc?.cgSizeValue.height == 70)
    }
    
    //MARK: - InstreamVideoAdUnit
    func testInstreamVideoAdUnitCreation() {
        //when
        let adUnit = InstreamVideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1))
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    //MARK: - VideoAdUnit
    
    func testVideoAdUnitCreation() {
        //when
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1))
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    //MARK: - VideoInterstitialAdUnit
    
    func testVideoInterstitialAdUnitCreation() {
        //when
        let adUnit = VideoInterstitialAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isInterstitialAd)
        XCTAssertTrue(adUnit.adUnitConfig.adPosition == .fullScreen)
        XCTAssertTrue(adUnit.adUnitConfig.adFormats == [.video])
    }
    
    func testVideoInterstitialAdUnitConvenienceCreation() {
        let adUnit = VideoInterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        XCTAssertTrue(adUnit.adUnitConfig.minSizePerc?.cgSizeValue.width == 50 && adUnit.adUnitConfig.minSizePerc?.cgSizeValue.height == 70)
    }
    
    //MARK: - RewardedVideoAdUnit
    func testRewardedVideoAdUnitCreation() {
        //when
        let adUnit = RewardedVideoAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
        XCTAssertTrue(adUnit.adUnitConfig.adConfiguration.isInterstitialAd)
        XCTAssertTrue(adUnit.adUnitConfig.adPosition == .fullScreen)
        XCTAssertTrue(adUnit.adUnitConfig.adFormats == [.video])
    }
    
    func testVideoRewardedAdUnitConvenienceCreation() {
        let adUnit = RewardedVideoAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        XCTAssertTrue(adUnit.adUnitConfig.minSizePerc?.cgSizeValue.width == 50 && adUnit.adUnitConfig.minSizePerc?.cgSizeValue.height == 70)
    }
    
    //MARK: - VideoBaseAdUnit
    func testVideoParametersCreation() {
        //given
        let videoAdUnit = InstreamVideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2))
        
        let videoInterstitialAdUnit = InterstitialAdUnit(configId: Constants.configID1)
        videoInterstitialAdUnit.adFormats = [.video]
        
        let rewardedVideoAdUnit = RewardedVideoAdUnit(configId: Constants.configID1)
        
        let videoBaseAdUnitArr: [VideoBasedAdUnitProtocol] = [videoAdUnit, videoInterstitialAdUnit, rewardedVideoAdUnit]
        
        for videoBaseAdUnit in videoBaseAdUnitArr {
            checkVideoParametersHelper(videoBaseAdUnit)
        }
    }
    
    //MARK: - private zone
    private func checkDefault(adUnit: AdUnit) {
        XCTAssertEqual(1, adUnit.adSizes.count)
        XCTAssertEqual(Constants.configID1, adUnit.adUnitConfig.configId)
        XCTAssertNil(adUnit.dispatcher)
    }
    
    private func checkVideoParametersHelper(_ videoBaseAdUnit: VideoBasedAdUnitProtocol) {
        let adUnit = videoBaseAdUnit
        
        let parameters = VideoParameters(mimes: ["video/x-flv", "video/mp4"])
        parameters.api = [Signals.Api.VPAID_1, Signals.Api.VPAID_2]
        parameters.maxBitrate = 1500
        parameters.minBitrate = 300
        parameters.maxDuration = 30
        parameters.minDuration = 5
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn, Signals.PlaybackMethod.ClickToPlay]
        parameters.protocols = [Signals.Protocols.VAST_2_0, Signals.Protocols.VAST_3_0]
        parameters.startDelay = Signals.StartDelay.PreRoll
        
        adUnit.videoParameters = parameters
        
        //when
        let videoParameters = videoBaseAdUnit.videoParameters
        
        //then
        guard let api = videoParameters.api,
              let maxBitrate = videoParameters.maxBitrate,
              let minBitrate = videoParameters.minBitrate,
              let maxDuration = videoParameters.maxDuration,
              let minDuration = videoParameters.minDuration,
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
        XCTAssertEqual(2, videoParameters.mimes.count)
        XCTAssert(videoParameters.mimes.contains("video/x-flv") && videoParameters.mimes.contains("video/mp4"))
        XCTAssertEqual(2, playbackMethod.count)
        XCTAssert(playbackMethod.contains(1) && playbackMethod.contains(3))
        XCTAssertEqual(2, protocols.count)
        XCTAssert(protocols.contains(2) && protocols.contains(3))
        XCTAssertEqual(0, startDelay)
    }
    
    private func checkBannerParametersHelper(_ bannerBasedAdUnit: BannerBasedAdUnitProtocol) {
        
        let adUnit = bannerBasedAdUnit
        
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.VPAID_1, Signals.Api.VPAID_2]
        
        adUnit.bannerParameters = parameters
        
        //when
        let testedBannerParameters = adUnit.bannerParameters
        
        //then
        guard let api = testedBannerParameters.api else {
            XCTFail("parsing fail")
            return
        }
        
        XCTAssertEqual(2, api.count)
        XCTAssert(api.contains(1) && api.contains(2))
    }
    
}

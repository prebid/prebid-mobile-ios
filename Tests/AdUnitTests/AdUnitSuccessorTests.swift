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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //MARK: - BannerAdUnit
    func testBannerAdUnitCreation() {
        //when
        let adUnit = BannerAdUnit(configId: configId, size: CGSize(width: Constants.width2, height: Constants.height2))

        //then
        checkDefault(adUnit: adUnit)
    }

    func testBannerAdUnitAddSize() {
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1))
        adUnit.adSizes = [CGSize(width: Constants.width1, height: Constants.height1), CGSize(width: Constants.width2, height: Constants.height2)]
        XCTAssertEqual(2, adUnit.adSizes.count)
    }
    
    //MARK: - InterstitialAdUnit
    func testInterstitialAdUnitCreation() {
        //when
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    func testInterstitialAdUnitConvenienceCreation() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        XCTAssertTrue(adUnit.minSizePerc?.width == 50 && adUnit.minSizePerc?.height == 70)
    }
    
    //MARK: - VideoAdUnit
    func testVideoAdUnitCreation() {
        //when
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1), type: .inBanner)
        
        //then
        checkDefault(adUnit: adUnit)
        
        XCTAssertEqual(.inBanner, adUnit.type)
    }
    
    //MARK: - VideoInterstitialAdUnit
    func testVideoInterstitialAdUnitCreation() {
        //when
        let adUnit = VideoInterstitialAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    //MARK: - RewardedVideoAdUnit
    func testRewardedVideoAdUnitCreation() {
        //when
        let adUnit = RewardedVideoAdUnit(configId: Constants.configID1)
        
        //then
        checkDefault(adUnit: adUnit)
    }
    
    //MARK: - private zone
    private func checkDefault(adUnit: AdUnit) {
        XCTAssertEqual(1, adUnit.adSizes.count)
        XCTAssertEqual(Constants.configID1, adUnit.prebidConfigId)
        XCTAssertNil(adUnit.dispatcher)
    }

}

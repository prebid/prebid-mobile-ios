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

class PBMInterstitialLayoutConfiguratorTest: XCTestCase {
    
    func testAdSizeConstants() {
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 200)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 320)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 35000)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 22, height: 22)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isPortrait(CGSize.zero))

        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 300, height: 400)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 270, height: 480)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 25000, height: 20)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 66, height: 66)))
        XCTAssertFalse(PBMInterstitialLayoutConfigurator.isLandscape(CGSize.zero))
        
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 270, height: 480)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 300, height: 1050)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 320, height: 480)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 480)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 640)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 640)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 576, height: 1024)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 720, height: 1280)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 768, height: 1024)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 960, height: 1280)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1080, height: 1920)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1440, height: 1920)))
        
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 320)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 360)))
        XCTAssertTrue(PBMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 1024, height: 768)))
    }
    
    func testDefaultAdConfiguration() {
        let displayProperties = PBMInterstitialDisplayProperties()
        let adConfig = AdConfiguration()
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.undefined.rawValue)
        
        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.aspectRatio.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    func testAdConfigurationWithSetLayout() {
        let displayProperties = PBMInterstitialDisplayProperties()
        let adConfig = AdConfiguration()
        
        adConfig.interstitialLayout = .portrait
        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .landscape
        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .aspectRatio
        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .undefined
        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.aspectRatio.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    // FIXME: - Auto rotation is enabled by default for now. 
//    func testAdConfigurationNoLayoutWithSize() {
//        let displayProperties = PBMInterstitialDisplayProperties()
//        let adConfig = AdConfiguration()
//
//        //test portrait size
//        adConfig.size = CGSize(width: 360, height: 480)
//        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
//        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.portrait.rawValue)
//        XCTAssertFalse(displayProperties.isRotationEnabled)
//
//        //test landscape size
//        adConfig.size = CGSize(width: 1024, height: 768)
//        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
//        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.landscape.rawValue)
//        XCTAssertFalse(displayProperties.isRotationEnabled)
//
//        //test aspectRatio size
//        adConfig.size = CGSize(width: 400, height: 300)
//        PBMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
//        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, PBMInterstitialLayout.aspectRatio.rawValue)
//        XCTAssertTrue(displayProperties.isRotationEnabled)
//    }
}

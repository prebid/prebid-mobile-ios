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
@_spi(PBMInternal) @testable import PrebidMobile

class PBMInterstitialLayoutConfiguratorTest: XCTestCase {
    
    func testAdSizeConstants() {
        XCTAssertFalse(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 200)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 320)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 35000)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 22, height: 22)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isPortrait(CGSize.zero))

        XCTAssertFalse(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 300, height: 400)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 270, height: 480)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 25000, height: 20)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 66, height: 66)))
        XCTAssertFalse(InterstitialLayoutConfigurator.isLandscape(CGSize.zero))
        
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 270, height: 480)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 300, height: 1050)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 320, height: 480)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 480)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 640)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 640)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 576, height: 1024)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 720, height: 1280)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 768, height: 1024)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 960, height: 1280)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 1080, height: 1920)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isPortrait(CGSize(width: 1440, height: 1920)))
        
        XCTAssertTrue(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 320)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 360)))
        XCTAssertTrue(InterstitialLayoutConfigurator.isLandscape(CGSize(width: 1024, height: 768)))
    }
    
    func testDefaultAdConfiguration() {
        let displayProperties = InterstitialDisplayProperties()
        let adConfig = AdConfiguration()
        XCTAssertEqual(displayProperties.interstitialLayout, .undefined)
        
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        
        XCTAssertEqual(displayProperties.interstitialLayout, .aspectRatio)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    func testAdConfigurationWithSetLayout() {
        let displayProperties = InterstitialDisplayProperties()
        let adConfig = AdConfiguration()
        
        adConfig.interstitialLayout = .portrait
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, adConfig.interstitialLayout)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .landscape
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, adConfig.interstitialLayout)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .aspectRatio
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, adConfig.interstitialLayout)
        XCTAssertTrue(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .undefined
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, .aspectRatio)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    func testAdConfigurationNoLayoutWithSize() {
        let displayProperties = InterstitialDisplayProperties()
        let adConfig = AdConfiguration()

        // test portrait size
        adConfig.size = CGSize(width: 360, height: 480)
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, .portrait)
        XCTAssertFalse(displayProperties.isRotationEnabled)

        // test landscape size
        adConfig.size = CGSize(width: 1024, height: 768)
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, .landscape)
        XCTAssertFalse(displayProperties.isRotationEnabled)

        // test unknown size
        adConfig.size = CGSize(width: 400, height: 300)
        InterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout, .aspectRatio)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
}

//
//  OXMInterstitialLayoutConfiguratorTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMInterstitialLayoutConfiguratorTest: XCTestCase {
    
    func testAdSizeConstants() {
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 200)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 320)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1000, height: 35000)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 22, height: 22)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isPortrait(CGSize.zero))

        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 300, height: 400)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 270, height: 480)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 25000, height: 20)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 66, height: 66)))
        XCTAssertFalse(OXMInterstitialLayoutConfigurator.isLandscape(CGSize.zero))
        
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 270, height: 480)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 300, height: 1050)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 320, height: 480)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 480)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 360, height: 640)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 480, height: 640)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 576, height: 1024)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 720, height: 1280)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 768, height: 1024)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 960, height: 1280)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1080, height: 1920)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isPortrait(CGSize(width: 1440, height: 1920)))
        
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 320)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 480, height: 360)))
        XCTAssertTrue(OXMInterstitialLayoutConfigurator.isLandscape(CGSize(width: 1024, height: 768)))
    }
    
    func testDefaultAdConfiguration() {
        let displayProperties = OXMInterstitialDisplayProperties()
        let adConfig = OXMAdConfiguration()
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.undefined.rawValue)
        
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.aspectRatio.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    func testAdConfigurationWithSetLayout() {
        let displayProperties = OXMInterstitialDisplayProperties()
        let adConfig = OXMAdConfiguration()
        
        adConfig.interstitialLayout = .portrait
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .landscape
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .aspectRatio
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, adConfig.interstitialLayout.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
        
        adConfig.interstitialLayout = .undefined
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.aspectRatio.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
    
    func testAdConfigurationNoLayoutWithSize() {
        let displayProperties = OXMInterstitialDisplayProperties()
        let adConfig = OXMAdConfiguration()
        
        //test portrait size
        adConfig.size = CGSize(width: 360, height: 480)
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.portrait.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        //test landscape size
        adConfig.size = CGSize(width: 1024, height: 768)
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.landscape.rawValue)
        XCTAssertFalse(displayProperties.isRotationEnabled)
        
        //test aspectRatio size
        adConfig.size = CGSize(width: 400, height: 300)
        OXMInterstitialLayoutConfigurator.configureProperties(with: adConfig, displayProperties: displayProperties)
        XCTAssertEqual(displayProperties.interstitialLayout.rawValue, OXMInterstitialLayout.aspectRatio.rawValue)
        XCTAssertTrue(displayProperties.isRotationEnabled)
    }
}

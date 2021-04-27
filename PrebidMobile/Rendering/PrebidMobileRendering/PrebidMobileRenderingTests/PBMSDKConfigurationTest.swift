//
//  PBMSDKConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMSDKConfigurationTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        PBMSDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = PBMSDKConfiguration.singleton
        
        // PBMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)

        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.prebidServerHost, .custom)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        PBMSDKConfiguration.initializeSDK()
        
        let log = PBMLog.singleton.getLogFileAsString()
        
        XCTAssert(log.contains("prebid-mobile-sdk-rendering \(PBMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after PBMLog will be ported
        
        let sdkConfiguration = PBMSDKConfiguration.singleton

        XCTAssertEqual(sdkConfiguration.logLevel, PBMLog.singleton.logLevel)
        
        sdkConfiguration.logLevel = PBMLogLevel.none
        XCTAssertEqual(PBMLog.singleton.logLevel, PBMLogLevel.none)
        
        PBMLog.singleton.logLevel = PBMLogLevel.info
        XCTAssertEqual(sdkConfiguration.logLevel, PBMLogLevel.info)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = PBMSDKConfiguration.singleton
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, PBMLog.singleton.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(PBMLog.singleton.logToFile, !initialValue)

        PBMLog.singleton.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = PBMSDKConfiguration.singleton
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testSingleton() {
        let firstConfig = PBMSDKConfiguration.singleton
        let newConfig = PBMSDKConfiguration.singleton
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetSingleton() {
        let firstConfig = PBMSDKConfiguration.singleton
        PBMSDKConfiguration.resetSingleton()
        let newConfig = PBMSDKConfiguration.singleton
        XCTAssertNotEqual(firstConfig, newConfig)
    }
    
    func testPrebidHost() {
        let sdkConfig = PBMSDKConfiguration.singleton
        XCTAssertEqual(sdkConfig.prebidServerHost, .custom)
        
        sdkConfig.prebidServerHost = .appnexus
        XCTAssertEqual(try! PBMHost.shared.getHostURL(host:sdkConfig.prebidServerHost), "https://prebid.adnxs.com/pbs/v1/openrtb2/auction")
        
        let _ = try! PBMSDKConfiguration.singleton.setCustomPrebidServer(url: "https://10.0.2.2:8000/openrtb2/auction")
        XCTAssertEqual(sdkConfig.prebidServerHost, .custom)
        
    }
    
    func testServerHostCustomInvalid() throws {
        XCTAssertThrowsError(try PBMSDKConfiguration.singleton.setCustomPrebidServer(url: "wrong url"))
    }
}

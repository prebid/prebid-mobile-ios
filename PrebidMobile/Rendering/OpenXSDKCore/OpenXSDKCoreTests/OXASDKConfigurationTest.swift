//
//  OXASDKConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXASDKConfigurationTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = OXASDKConfiguration.singleton
        
        // OXMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)

        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.serverURL, OXASDKConfiguration.prodServerURL)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        OXASDKConfiguration.initializeSDK()
        
        let log = OXMLog.singleton.getLogFileAsString()
        
        XCTAssert(log.contains("OpenXSDK \(OXMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after OXMLog will be ported
        
        let sdkConfiguration = OXASDKConfiguration.singleton

        XCTAssertEqual(sdkConfiguration.logLevel, OXMLog.singleton.logLevel)
        
        sdkConfiguration.logLevel = OXALogLevel.none
        XCTAssertEqual(OXMLog.singleton.logLevel, OXALogLevel.none)
        
        OXMLog.singleton.logLevel = OXALogLevel.info
        XCTAssertEqual(sdkConfiguration.logLevel, OXALogLevel.info)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = OXASDKConfiguration.singleton
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, OXMLog.singleton.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(OXMLog.singleton.logToFile, !initialValue)

        OXMLog.singleton.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = OXASDKConfiguration.singleton
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testSingleton() {
        let firstConfig = OXASDKConfiguration.singleton
        let newConfig = OXASDKConfiguration.singleton
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetSingleton() {
        let firstConfig = OXASDKConfiguration.singleton
        OXASDKConfiguration.resetSingleton()
        let newConfig = OXASDKConfiguration.singleton
        XCTAssertNotEqual(firstConfig, newConfig)
    }
}

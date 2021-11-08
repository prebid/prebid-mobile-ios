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

class PBMSDKConfigurationTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        PrebidRenderingConfig.reset()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = PrebidRenderingConfig.shared
        
        checkInitialValue(sdkConfiguration: sdkConfiguration)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        PrebidRenderingConfig.initializeRenderingModule()
        
        let log = PBMLog.shared.getLogFileAsString()
        
        XCTAssert(log.contains("prebid-mobile-sdk-rendering \(PBMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after PBMLog will be ported
        
        let sdkConfiguration = PrebidRenderingConfig.shared
        
        XCTAssertEqual(sdkConfiguration.logLevel, PBMLog.shared.logLevel)
        
        sdkConfiguration.logLevel = PBMLogLevel.none
        XCTAssertEqual(PBMLog.shared.logLevel, PBMLogLevel.none)
        
        PBMLog.shared.logLevel = PBMLogLevel.info
        XCTAssertEqual(sdkConfiguration.logLevel, PBMLogLevel.info)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = PrebidRenderingConfig.shared
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, PBMLog.shared.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(PBMLog.shared.logToFile, !initialValue)
        
        PBMLog.shared.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = PrebidRenderingConfig.shared
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testShared() {
        let firstConfig = PrebidRenderingConfig.shared
        let newConfig = PrebidRenderingConfig.shared
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetShared() {
        let firstConfig = PrebidRenderingConfig.shared
        firstConfig.accountID = "test"
        PrebidRenderingConfig.reset()
        
        checkInitialValue(sdkConfiguration: firstConfig)
    }
    
    func testPrebidHost() {
        let sdkConfig = PrebidRenderingConfig.shared
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
        
        sdkConfig.prebidServerHost = .Appnexus
        XCTAssertEqual(try! Host.shared.getHostURL(host:sdkConfig.prebidServerHost), "https://prebid.adnxs.com/pbs/v1/openrtb2/auction")
        
        let _ = try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://10.0.2.2:8000/openrtb2/auction")
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
    }
    
    func testServerHostCustomInvalid() throws {
        XCTAssertThrowsError(try PrebidRenderingConfig.shared.setCustomPrebidServer(url: "wrong url"))
    }
    
    // MARK: - Private Methods
    
    private func checkInitialValue(sdkConfiguration: PrebidRenderingConfig, file: StaticString = #file, line: UInt = #line) {
        // PBMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)
        
        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.prebidServerHost, .Custom)
    }
}

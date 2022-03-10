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

class PrebidConfigurationTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        PrebidConfiguration.reset()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = PrebidConfiguration.shared
        
        checkInitialValue(sdkConfiguration: sdkConfiguration)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        PrebidConfiguration.initializeRenderingModule()
        
        let log = PBMLog.shared.getLogFileAsString()
        
        XCTAssert(log.contains("prebid-mobile-sdk \(PBMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after PBMLog will be ported
        
        let sdkConfiguration = PrebidConfiguration.shared
        
        XCTAssertEqual(sdkConfiguration.logLevel, Log.logLevel)
        
        sdkConfiguration.logLevel = .verbose
        XCTAssertEqual(Log.logLevel, .verbose)
        
        Log.logLevel = .warn
        XCTAssertEqual(sdkConfiguration.logLevel, .warn)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = PrebidConfiguration.shared
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, PBMLog.shared.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(PBMLog.shared.logToFile, !initialValue)
        
        PBMLog.shared.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = PrebidConfiguration.shared
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testShared() {
        let firstConfig = PrebidConfiguration.shared
        let newConfig = PrebidConfiguration.shared
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetShared() {
        let firstConfig = PrebidConfiguration.shared
        firstConfig.accountID = "test"
        PrebidConfiguration.reset()
        
        checkInitialValue(sdkConfiguration: firstConfig)
    }
    
    func testPrebidHost() {
        let sdkConfig = PrebidConfiguration.shared
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
        
        sdkConfig.prebidServerHost = .Appnexus
        XCTAssertEqual(try! Host.shared.getHostURL(host:sdkConfig.prebidServerHost), "https://prebid.adnxs.com/pbs/v1/openrtb2/auction")
        
        let _ = try! PrebidConfiguration.shared.setCustomPrebidServer(url: "https://10.0.2.2:8000/openrtb2/auction")
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
    }
    
    func testServerHostCustomInvalid() throws {
        XCTAssertThrowsError(try PrebidConfiguration.shared.setCustomPrebidServer(url: "wrong url"))
    }
    
    func testServerHost() {
        //given
        let case1 = PrebidHost.Appnexus
        let case2 = PrebidHost.Rubicon
        
        //when
        PrebidConfiguration.shared.prebidServerHost = case1
        let result1 = PrebidConfiguration.shared.prebidServerHost
        
        PrebidConfiguration.shared.prebidServerHost = case2
        let result2 = PrebidConfiguration.shared.prebidServerHost
        
        //then
        XCTAssertEqual(case1, result1)
        XCTAssertEqual(case2, result2)
    }
    
    func testServerHostCustom() throws {
        //given
        let customHost = "https://prebid-server.rubiconproject.com/openrtb2/auction"
        
        //when
        //We can not use setCustomPrebidServer() because it uses UIApplication.shared.canOpenURL
//        try! PrebidConfiguration.shared.setCustomPrebidServer(url: customHost)
        
        PrebidConfiguration.shared.prebidServerHost = PrebidHost.Custom
        try Host.shared.setCustomHostURL(customHost)
        
        //then
        XCTAssertEqual(PrebidHost.Custom, PrebidConfiguration.shared.prebidServerHost)
        let getHostURLResult = try Host.shared.getHostURL(host: .Custom)
        XCTAssertEqual(customHost, getHostURLResult)
    }
    
    func testAccountId() {
        //given
        let serverAccountId = "123"
        
        //when
        PrebidConfiguration.shared.prebidServerAccountId = serverAccountId
        
        //then
        XCTAssertEqual(serverAccountId, PrebidConfiguration.shared.prebidServerAccountId)
    }

    func testStoredAuctionResponse() {
        //given
        let storedAuctionResponse = "111122223333"
        
        //when
        PrebidConfiguration.shared.storedAuctionResponse = storedAuctionResponse
        
        //then
        XCTAssertEqual(storedAuctionResponse, PrebidConfiguration.shared.storedAuctionResponse)
    }
    
    func testAddStoredBidResponse() {
        
        //given
        let appnexusBidder = "appnexus"
        let appnexusResponseId = "221144"
        
        let rubiconBidder = "rubicon"
        let rubiconResponseId = "221155"
        
        //when
        PrebidConfiguration.shared.addStoredBidResponse(bidder: appnexusBidder, responseId: appnexusResponseId)
        PrebidConfiguration.shared.addStoredBidResponse(bidder: rubiconBidder, responseId: rubiconResponseId)
        
        //then
        let dict = PrebidConfiguration.shared.storedBidResponses
        XCTAssertEqual(2, dict.count)
        XCTAssert(dict[appnexusBidder] == appnexusResponseId && dict[rubiconBidder] == rubiconResponseId )
    }
    
    func testClearStoredBidResponses() {
        
        //given
        PrebidConfiguration.shared.addStoredBidResponse(bidder: "rubicon", responseId: "221155")
        let case1 = PrebidConfiguration.shared.storedBidResponses.count
        
        //when
        PrebidConfiguration.shared.clearStoredBidResponses()
        let case2 = PrebidConfiguration.shared.storedBidResponses.count
        
        //then
        XCTAssertNotEqual(0, case1)
        XCTAssertEqual(0, case2)
    }

    func testAddCustomHeader() {

        //given
        let sdkVersionHeader = "X-SDK-Version"
        let bundleHeader = "X-Bundle"

        let sdkVersion = "1.1.666"
        let bundleName = "com.app.nextAd"

        //when
        PrebidConfiguration.shared.addCustomHeader(name: sdkVersionHeader, value: sdkVersion)
        PrebidConfiguration.shared.addCustomHeader(name: bundleHeader, value: bundleName)

        //then
        let dict = PrebidConfiguration.shared.customHeaders
        XCTAssertEqual(2, dict.count)
        XCTAssert(dict[sdkVersionHeader] == sdkVersion && dict[bundleHeader] == bundleName )
    }

    func testClearCustomHeaders() {

        //given
        PrebidConfiguration.shared.addCustomHeader(name: "header", value: "value")
        let case1 = PrebidConfiguration.shared.customHeaders.count

        //when
        PrebidConfiguration.shared.clearCustomHeaders()
        let case2 = PrebidConfiguration.shared.customHeaders.count

        //then
        XCTAssertNotEqual(0, case1)
        XCTAssertEqual(0, case2)
    }
    
    func testShareGeoLocation() {
        //given
        let case1 = true
        let case2 = false
        
        //when
        PrebidConfiguration.shared.shareGeoLocation = case1
        let result1 = PrebidConfiguration.shared.shareGeoLocation
        
        PrebidConfiguration.shared.shareGeoLocation = case2
        let result2 = PrebidConfiguration.shared.shareGeoLocation
        
        //rhen
        XCTAssertEqual(case1, result1)
        XCTAssertEqual(case2, result2)
    }
    
    func testTimeoutMillis() {
        //given
        let timeoutMillis =  3_000
        
        //when
        PrebidConfiguration.shared.bidRequestTimeoutMillis = timeoutMillis
        
        //then
        XCTAssertEqual(timeoutMillis, PrebidConfiguration.shared.bidRequestTimeoutMillis)
    }
    
    func testBidderName() {
        XCTAssertEqual("appnexus", PrebidConfiguration.bidderNameAppNexus)
        XCTAssertEqual("rubicon", PrebidConfiguration.bidderNameRubiconProject)
    }
    
    func testPbsDebug() {
        //given
        let pbsDebug = true
        
        //when
        PrebidConfiguration.shared.pbsDebug = pbsDebug
        
        //then
        XCTAssertEqual(pbsDebug, PrebidConfiguration.shared.pbsDebug)
    }
    
    // MARK: - Private Methods
    
    private func checkInitialValue(sdkConfiguration: PrebidConfiguration, file: StaticString = #file, line: UInt = #line) {
        // PBMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)
        
        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.prebidServerHost, .Custom)
    }
}

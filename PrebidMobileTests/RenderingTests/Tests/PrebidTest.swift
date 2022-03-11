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

class PrebidTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = Prebid.shared
        
        checkInitialValue(sdkConfiguration: sdkConfiguration)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        Prebid.initializeModule()
        
        let log = PBMLog.shared.getLogFileAsString()
        
        XCTAssert(log.contains("prebid-mobile-sdk \(PBMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after PBMLog will be ported
        
        let sdkConfiguration = Prebid.shared
        
        XCTAssertEqual(sdkConfiguration.logLevel, Log.logLevel)
        
        sdkConfiguration.logLevel = .verbose
        XCTAssertEqual(Log.logLevel, .verbose)
        
        Log.logLevel = .warn
        XCTAssertEqual(sdkConfiguration.logLevel, .warn)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = Prebid.shared
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, PBMLog.shared.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(PBMLog.shared.logToFile, !initialValue)
        
        PBMLog.shared.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = Prebid.shared
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testShared() {
        let firstConfig = Prebid.shared
        let newConfig = Prebid.shared
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetShared() {
        let firstConfig = Prebid.shared
        firstConfig.accountID = "test"
        Prebid.reset()
        
        checkInitialValue(sdkConfiguration: firstConfig)
    }
    
    func testPrebidHost() {
        let sdkConfig = Prebid.shared
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
        
        sdkConfig.prebidServerHost = .Appnexus
        XCTAssertEqual(try! Host.shared.getHostURL(host:sdkConfig.prebidServerHost), "https://prebid.adnxs.com/pbs/v1/openrtb2/auction")
        
        let _ = try! Prebid.shared.setCustomPrebidServer(url: "https://10.0.2.2:8000/openrtb2/auction")
        XCTAssertEqual(sdkConfig.prebidServerHost, .Custom)
    }
    
    func testServerHostCustomInvalid() throws {
        XCTAssertThrowsError(try Prebid.shared.setCustomPrebidServer(url: "wrong url"))
    }
    
    func testServerHost() {
        //given
        let case1 = PrebidHost.Appnexus
        let case2 = PrebidHost.Rubicon
        
        //when
        Prebid.shared.prebidServerHost = case1
        let result1 = Prebid.shared.prebidServerHost
        
        Prebid.shared.prebidServerHost = case2
        let result2 = Prebid.shared.prebidServerHost
        
        //then
        XCTAssertEqual(case1, result1)
        XCTAssertEqual(case2, result2)
    }
    
    func testServerHostCustom() throws {
        //given
        let customHost = "https://prebid-server.rubiconproject.com/openrtb2/auction"
        
        //when
        //We can not use setCustomPrebidServer() because it uses UIApplication.shared.canOpenURL
//        try! Prebid.shared.setCustomPrebidServer(url: customHost)
        
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        try Host.shared.setCustomHostURL(customHost)
        
        //then
        XCTAssertEqual(PrebidHost.Custom, Prebid.shared.prebidServerHost)
        let getHostURLResult = try Host.shared.getHostURL(host: .Custom)
        XCTAssertEqual(customHost, getHostURLResult)
    }
    
    func testAccountId() {
        //given
        let serverAccountId = "123"
        
        //when
        Prebid.shared.prebidServerAccountId = serverAccountId
        
        //then
        XCTAssertEqual(serverAccountId, Prebid.shared.prebidServerAccountId)
    }

    func testStoredAuctionResponse() {
        //given
        let storedAuctionResponse = "111122223333"
        
        //when
        Prebid.shared.storedAuctionResponse = storedAuctionResponse
        
        //then
        XCTAssertEqual(storedAuctionResponse, Prebid.shared.storedAuctionResponse)
    }
    
    func testAddStoredBidResponse() {
        
        //given
        let appnexusBidder = "appnexus"
        let appnexusResponseId = "221144"
        
        let rubiconBidder = "rubicon"
        let rubiconResponseId = "221155"
        
        //when
        Prebid.shared.addStoredBidResponse(bidder: appnexusBidder, responseId: appnexusResponseId)
        Prebid.shared.addStoredBidResponse(bidder: rubiconBidder, responseId: rubiconResponseId)
        
        //then
        let dict = Prebid.shared.storedBidResponses
        XCTAssertEqual(2, dict.count)
        XCTAssert(dict[appnexusBidder] == appnexusResponseId && dict[rubiconBidder] == rubiconResponseId )
    }
    
    func testClearStoredBidResponses() {
        
        //given
        Prebid.shared.addStoredBidResponse(bidder: "rubicon", responseId: "221155")
        let case1 = Prebid.shared.storedBidResponses.count
        
        //when
        Prebid.shared.clearStoredBidResponses()
        let case2 = Prebid.shared.storedBidResponses.count
        
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
        Prebid.shared.addCustomHeader(name: sdkVersionHeader, value: sdkVersion)
        Prebid.shared.addCustomHeader(name: bundleHeader, value: bundleName)

        //then
        let dict = Prebid.shared.customHeaders
        XCTAssertEqual(2, dict.count)
        XCTAssert(dict[sdkVersionHeader] == sdkVersion && dict[bundleHeader] == bundleName )
    }

    func testClearCustomHeaders() {

        //given
        Prebid.shared.addCustomHeader(name: "header", value: "value")
        let case1 = Prebid.shared.customHeaders.count

        //when
        Prebid.shared.clearCustomHeaders()
        let case2 = Prebid.shared.customHeaders.count

        //then
        XCTAssertNotEqual(0, case1)
        XCTAssertEqual(0, case2)
    }
    
    func testShareGeoLocation() {
        //given
        let case1 = true
        let case2 = false
        
        //when
        Prebid.shared.shareGeoLocation = case1
        let result1 = Prebid.shared.shareGeoLocation
        
        Prebid.shared.shareGeoLocation = case2
        let result2 = Prebid.shared.shareGeoLocation
        
        //rhen
        XCTAssertEqual(case1, result1)
        XCTAssertEqual(case2, result2)
    }
    
    func testTimeoutMillis() {
        //given
        let timeoutMillis =  3_000
        
        //when
        Prebid.shared.bidRequestTimeoutMillis = timeoutMillis
        
        //then
        XCTAssertEqual(timeoutMillis, Prebid.shared.bidRequestTimeoutMillis)
    }
    
    func testBidderName() {
        XCTAssertEqual("appnexus", Prebid.bidderNameAppNexus)
        XCTAssertEqual("rubicon", Prebid.bidderNameRubiconProject)
    }
    
    func testPbsDebug() {
        //given
        let pbsDebug = true
        
        //when
        Prebid.shared.pbsDebug = pbsDebug
        
        //then
        XCTAssertEqual(pbsDebug, Prebid.shared.pbsDebug)
    }
    
    // MARK: - Private Methods
    
    private func checkInitialValue(sdkConfiguration: Prebid, file: StaticString = #file, line: UInt = #line) {
        // PBMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)
        
        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.prebidServerHost, .Custom)
    }
}

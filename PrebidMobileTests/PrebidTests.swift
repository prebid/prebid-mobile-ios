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

class OriginalSDKConfigurationTests: XCTestCase {

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
    
    func testServerHostCustomInvalid() throws {

        XCTAssertThrowsError(try PrebidConfiguration.shared.setCustomPrebidServer(url: "wrong url"))
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
    
    func testLogLevel() {
        //given
        let logLevel = LogLevel.verbose
        
        //when
        PrebidConfiguration.shared.logLevel = logLevel
        
        //then
        XCTAssertEqual(logLevel, PrebidConfiguration.shared.logLevel)
        
    }
    
    func testBidderName() {
        XCTAssertEqual("appnexus", Prebid.bidderNameAppNexus)
        XCTAssertEqual("rubicon", Prebid.bidderNameRubiconProject)
    }
    
    func testPbsDebug() {
        //given
        let pbsDebug = true
        
        //when
        PrebidConfiguration.shared.pbsDebug = pbsDebug
        
        //then
        XCTAssertEqual(pbsDebug, PrebidConfiguration.shared.pbsDebug)
    }
}

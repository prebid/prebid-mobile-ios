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
    
    func testServerHostCustomInvalid() throws {

        XCTAssertThrowsError(try Prebid.shared.setCustomPrebidServer(url: "wrong url"))
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
        Prebid.shared.timeoutMillis = timeoutMillis
        
        //then
        XCTAssertEqual(timeoutMillis, Prebid.shared.timeoutMillis)
    }
    
    func testLogLevel() {
        //given
        let logLevel = LogLevel.verbose
        
        //when
        Prebid.shared.logLevel = logLevel
        
        //then
        XCTAssertEqual(logLevel, Prebid.shared.logLevel)
        
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
}

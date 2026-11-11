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

import Foundation

import XCTest
import CoreFoundation

@_spi(PBMInternal) @testable import PrebidMobile

class PBMVastLoaderCheckForAds : XCTestCase {
    
    let sdkConfiguration = Prebid.mock
    
    var wrapper1:VastWrapperAd! = nil
    var wrapper2:VastWrapperAd! = nil
    var inline:VastInlineAd! = nil
    
    var response1:VastResponse!
    var response2:VastResponse!
    var response3:VastResponse!
    
    var vastAdsBuilder:VastAdsBuilder?
    
    var expectationResponse1ErrorURICalled:XCTestExpectation!
    var expectationResponse2ErrorURICalled:XCTestExpectation!
    var expectationResponse3ErrorURICalled:XCTestExpectation!

    // The URL each no-ad rule received, as it was requested.
    var firedURL1: String?
    var firedURL2: String?
    
    override func setUp() {
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        self.vastAdsBuilder = VastAdsBuilder(connection: connection)
        
        wrapper1 = VastWrapperAd()
        wrapper2 = VastWrapperAd()
        inline = VastInlineAd()
        
        response1 = VastResponse()
        response2 = VastResponse()
        response3 = VastResponse()
        
        response1.noAdsResponseURI = "http://response1/noAds"
        response2.noAdsResponseURI = "http://response2/noAds"
        response3.noAdsResponseURI = "http://response3/noAds"
        
        MockServer.shared.reset()
        let rule1 =  MockServerRule(fireAndForgetURLNeedle: response1.noAdsResponseURI!, connectionID: connection.internalID)
        rule1.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.firedURL1 = urlRequest.url?.absoluteString
            self.fulfillOrFail(self.expectationResponse1ErrorURICalled, "expectationResponse1ErrorURICalled")
        }
        
        let rule2 = MockServerRule(fireAndForgetURLNeedle: response2.noAdsResponseURI!, connectionID: connection.internalID)
        rule2.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.firedURL2 = urlRequest.url?.absoluteString
            self.fulfillOrFail(self.expectationResponse2ErrorURICalled, "expectationResponse2ErrorURICalled")
        }
        
        let rule3 = MockServerRule(fireAndForgetURLNeedle: response3.noAdsResponseURI!, connectionID: connection.internalID)
        rule3.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fulfillOrFail(self.expectationResponse3ErrorURICalled, "expectationResponse3ErrorURICalled")
        }
        
        MockServer.shared.resetRules([rule1, rule2, rule3])
    }
    
    override func tearDown() {
        self.vastAdsBuilder = nil
        self.expectationResponse1ErrorURICalled = nil
        self.expectationResponse2ErrorURICalled = nil
        self.expectationResponse3ErrorURICalled = nil
        MockServer.shared.reset()
    }
    
    
    //A single response with an ad, whether it's an inline or wrapper should pass and not fire NoAds URIs.
    func testPositiveSingleInlineOrWrapper() {
        response1.vastAbstractAds = [inline!]
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
        
        response1.vastAbstractAds = [wrapper1!]
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }
    
    //A response with no ads should fire the response's noAdsURI.
    func testNegativeSingleNoAds() {
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    func testPositiveTwoResponses() {
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        response2.parentResponse = response1
        
        response2.vastAbstractAds = [inline!]
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }
    
    //A response with a nextResponse but no ads should fire that response's noAdsURI.
    func testNegativeTwoResponsesNoAdsOnSecond() {
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        self.expectationResponse2ErrorURICalled = self.expectation(description: "expectationResponse2ErrorURICalled")
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        //No Ads on response2
        response2.parentResponse = response1
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    func testPositiveThreeResponses() {
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        response2.parentResponse = response1
        response2.vastAbstractAds = [wrapper2!]
        wrapper2.vastResponse = response3
        
        response3.parentResponse = response2
        response3.vastAbstractAds = [inline!]
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }
    
    func testNegativeThreeResponsesNoAdsOnLast() {
        
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        self.expectationResponse2ErrorURICalled = self.expectation(description: "expectationResponse2ErrorURICalled")
        self.expectationResponse3ErrorURICalled = self.expectation(description: "expectationResponse3ErrorURICalled")
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        response2.parentResponse = response1
        response2.vastAbstractAds = [wrapper2!]
        wrapper2.vastResponse = response3
        
        //No ads on response3
        response3.parentResponse = response2
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }

    // A no-ad response parsed from XML should fire its VAST-level Error URI.
    func testNegativeNoAdsParsedFromXML() {
        let xml = """
        <VAST version="3.0">
            <Error><![CDATA[http://response1/noAds]]></Error>
        </VAST>
        """
        guard let response = VastParser().parseAdsResponse(Data(xml.utf8)) else {
            XCTFail("Could not parse the no-ad response")
            return
        }

        expectationResponse1ErrorURICalled = expectation(description: "expectationResponse1ErrorURICalled")

        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response) == true)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // The [ERRORCODE] macro in the Error URI of a no-ad response is replaced with 303 before the request.
    // Left in place, its brackets keep the URI from becoming a URL on iOS 17 and later.
    func testNegativeNoAdsErrorCodeMacroParsedFromXML() {
        let xml = """
        <VAST version="3.0">
            <Error><![CDATA[http://response1/noAds?code=[ERRORCODE]]]></Error>
        </VAST>
        """
        guard let response = VastParser().parseAdsResponse(Data(xml.utf8)) else {
            XCTFail("Could not parse the no-ad response")
            return
        }

        expectationResponse1ErrorURICalled = expectation(description: "expectationResponse1ErrorURICalled")

        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response) == true)

        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(firedURL1, "http://response1/noAds?code=303")
    }

    // Every Error URI up the wrapper chain gets 303, including the percent-encoded form of the macro.
    func testNegativeTwoResponsesNoAdsOnSecondErrorCodeMacro() {
        expectationResponse1ErrorURICalled = expectation(description: "expectationResponse1ErrorURICalled")
        expectationResponse2ErrorURICalled = expectation(description: "expectationResponse2ErrorURICalled")

        response1.noAdsResponseURI = "http://response1/noAds?code=[ERRORCODE]"
        response2.noAdsResponseURI = "http://response2/noAds?code=%5bERRORCODE%5d&again=[ERRORCODE]"

        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2

        // No ads on response2
        response2.parentResponse = response1

        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)

        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(firedURL1, "http://response1/noAds?code=303")
        XCTAssertEqual(firedURL2, "http://response2/noAds?code=303&again=303")
    }

    // An Error URI without the macro is requested unchanged.
    func testNegativeSingleNoAdsWithoutErrorCodeMacro() {
        expectationResponse1ErrorURICalled = expectation(description: "expectationResponse1ErrorURICalled")

        response1.noAdsResponseURI = "http://response1/noAds?code=900&cb=12345"

        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)

        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(firedURL1, "http://response1/noAds?code=900&cb=12345")
    }

    func testNoAdsAfterNestedWrappersRequestsEveryWrapperError() {
        let first = wrapperVast("http://wrapper/one", errors: [
            "http://error/one?code=[ERRORCODE]", "http://error/two?code=%5berrorcode%5d", "  "
        ])
        let second = wrapperVast("http://wrapper/two", errors: ["http://error/three?code=[ERRORCODE]"])
        let empty = "<VAST version=\"4.3\"><Error><![CDATA[http://error/empty?code=[ERRORCODE]]]></Error></VAST>"

        assertWrapperRequests(rootXML: first, responses: ["http://wrapper/one": second, "http://wrapper/two": empty],
                              expectedErrorURLs: ["http://error/one?code=303", "http://error/two?code=303",
                                                  "http://error/three?code=303", "http://error/empty?code=303"])
    }

    func testNoAdsWithoutRootErrorStillRequestsWrapperError() {
        assertWrapperRequests(rootXML: wrapperVast("http://wrapper/one", errors: ["http://error/one?code=[ERRORCODE]"]),
                              responses: ["http://wrapper/one": "<VAST version=\"4.3\"/>"],
                              expectedErrorURLs: ["http://error/one?code=303"])
    }

    func testSuccessfulWrapperDoesNotRequestNoAdErrors() throws {
        let inlineData = try XCTUnwrap(UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_inline_ad.xml"))
        assertWrapperRequests(rootXML: wrapperVast("http://wrapper/one", errors: ["http://error/one?code=[ERRORCODE]"]),
                              responses: ["http://wrapper/one": String(decoding: inlineData, as: UTF8.self)],
                              expectedErrorURLs: [], expectNoAds: false)
    }

    func testNoAdsDoesNotRequestSuccessfulSiblingWrapperError() throws {
        let inlineData = try XCTUnwrap(UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_inline_ad.xml"))
        let root = "<VAST version=\"4.3\">"
            + wrapperAdXML("http://wrapper/empty", errors: ["http://error/empty?code=[ERRORCODE]"])
            + wrapperAdXML("http://wrapper/filled", errors: ["http://error/filled?code=[ERRORCODE]"])
            + "</VAST>"
        assertWrapperRequests(rootXML: root,
                              responses: ["http://wrapper/empty": "<VAST version=\"4.3\"/>",
                                          "http://wrapper/filled": String(decoding: inlineData, as: UTF8.self)],
                              expectedErrorURLs: ["http://error/empty?code=303"])
    }

    func testNoAdsReportsBothEmptySiblingBranches() {
        let root = "<VAST version=\"4.3\">"
            + wrapperAdXML("http://wrapper/one", errors: ["http://error/one?code=[ERRORCODE]"])
            + wrapperAdXML("http://wrapper/two", errors: ["http://error/two?code=[ERRORCODE]"])
            + "</VAST>"
        assertWrapperRequests(rootXML: root,
                              responses: ["http://wrapper/one": "<VAST version=\"4.3\"/>",
                                          "http://wrapper/two": "<VAST version=\"4.3\"/>"],
                              expectedErrorURLs: ["http://error/one?code=303", "http://error/two?code=303"])
    }

    private func wrapperVast(_ url: String, errors: [String]) -> String {
        "<VAST version=\"4.3\">" + wrapperAdXML(url, errors: errors) + "</VAST>"
    }

    private func wrapperAdXML(_ url: String, errors: [String]) -> String {
        let errorXML = errors.map { "<Error><![CDATA[\($0)]]></Error>" }.joined()
        return "<Ad id=\"1\"><Wrapper><AdSystem>test</AdSystem>" + errorXML
            + "<VASTAdTagURI><![CDATA[\(url)]]></VASTAdTagURI></Wrapper></Ad>"
    }

    private func assertWrapperRequests(rootXML: String, responses: [String: String],
                                       expectedErrorURLs: [String], expectNoAds: Bool = true) {
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        vastAdsBuilder = VastAdsBuilder(connection: connection)
        var rules = responses.map { url, xml in
            MockServerRule(urlNeedle: url, mimeType: MockServerMimeType.XML.rawValue,
                           connectionID: connection.internalID, strResponse: xml)
        }
        for expectedURL in expectedErrorURLs {
            let called = expectation(description: expectedURL)
            let rule = MockServerRule(fireAndForgetURLNeedle: expectedURL, connectionID: connection.internalID)
            rule.mockServerReceivedRequestHandler = { request in
                XCTAssertEqual(request.url?.absoluteString, expectedURL)
                called.fulfill()
            }
            rules.append(rule)
        }
        MockServer.shared.resetRules(rules)
        MockServer.shared.notFoundRule.mockServerReceivedRequestHandler = { request in
            XCTFail("Unexpected request: \(request)")
        }
        let completed = expectation(description: "VAST load completed")
        vastAdsBuilder?.buildAds(Data(rootXML.utf8)) { ads, error in
            if expectNoAds {
                XCTAssertNil(ads)
                XCTAssertEqual(error?.localizedDescription, "One or more responses had no ads")
            } else {
                XCTAssertNil(error)
                XCTAssertEqual(ads?.count, 1)
            }
            completed.fulfill()
        }
        waitForExpectations(timeout: 3)
    }

}

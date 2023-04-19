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
@testable import PrebidMobile

class ServerConnectionTest : XCTestCase {
    
    let strPostData = "TEST"
    let strResponse = "{\"foo\":\"bar\"}"
    let expectedJSONDict = ["foo":"bar"]
    let invalidURL = "\u{1F44D}"
    
    var didTalkToServerExpectation:XCTestExpectation!
    var responseHandledExpectation:XCTestExpectation!
    
    override func setUp() {
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.didTalkToServerExpectation = nil
        self.responseHandledExpectation = nil
        Prebid.shared.clearCustomHeaders()
    }
    
    func testSharedCreation() {
        let serverConnectionShared = PrebidServerConnection.shared
        XCTAssertNotNil(serverConnectionShared)
        
        XCTAssert(serverConnectionShared === PrebidServerConnection.shared)

        let serverConnectionInstance = PrebidServerConnection()
        XCTAssert(serverConnectionShared !== serverConnectionInstance)
    }
    
    func testFireAndForget() {
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")

        let connection = getMockedServerConnection()
        
        //Mock a server to respond with JSON (the response will be ignored by fireAndForget)
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["key"] = "val"
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTAssertEqual(urlRequest.httpMethod, "GET")
            XCTAssertEqual(urlRequest.httpBody, nil)
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://foo.com/bo?param_key=abc123")
            XCTAssertEqual(urlRequest.allHTTPHeaderFields!, [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.isPBMRequestKey     : "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString
                ])
            
            self.didTalkToServerExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])

        //Test
        connection.fireAndForget("http://foo.com/bo?param_key=abc123")
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testFireAndForgetWithInvalidURL() {
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")
        self.didTalkToServerExpectation.isInverted = true
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with JSON (the response will be ignored by fireAndForget)
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["key"] = "val"
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.didTalkToServerExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])
        
        //Test
        connection.fireAndForget("http://foo.com/bo?param_key={abc123}")
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

    func testGet() {
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")
        self.responseHandledExpectation = self.expectation(description: "responseHandledExpectation")
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with JSON
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: self.strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["responseHeaderKey"] = "responseHeaderVal"
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTAssertEqual(urlRequest.httpMethod, "GET")
            XCTAssertEqual(urlRequest.httpBody, nil)
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://foo.com/bo?param_key=abc123")
            
            let expectedRequestHeaders = [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.contentTypeKey      : PrebidServerConnection.contentTypeVal,
                PrebidServerConnection.isPBMRequestKey     : "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString
            ]
            
            let actualRequestHeaders = urlRequest.allHTTPHeaderFields!
            XCTAssertEqual(expectedRequestHeaders, actualRequestHeaders, "expected \(expectedRequestHeaders), got \(actualRequestHeaders)")
            self.didTalkToServerExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])
        
        //Test
        connection.get("http://foo.com/bo?param_key=abc123", timeout:3.0, callback:{ (serverResponse:PrebidServerResponse) in
            XCTAssertNil(serverResponse.error, "\(String(describing: serverResponse.error))")
            XCTAssertEqual(serverResponse.statusCode, 123)

            let expectedResponseHeaders = [
                "responseHeaderKey":"responseHeaderVal",
                "Content-Type":"application/json",
                "Content-Length":"\(self.strResponse.count)"
            ]
            let actualResponseHeaders = serverResponse.responseHeaders!
            XCTAssertEqual(expectedResponseHeaders, actualResponseHeaders, "Expected \(expectedResponseHeaders), got \(actualResponseHeaders)")
            
            guard let jsonDict = serverResponse.jsonDict else {
                XCTFail("jsonDict is nil")
                return
            }
            
            guard let comparableJsonDict = jsonDict as? [String:String] else {
                XCTFail("Could not cast")
                return
            }
            
            PBMAssertEq(comparableJsonDict, self.expectedJSONDict)
            self.responseHandledExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

    func testGETWithInvalidURL() {
        self.didTalkToServerExpectation = unfulfilledExpectation(self, description: "didTalkToServerExpectation")

        let serverConnection = getMockedServerConnection()
        serverConnection.get(self.invalidURL, timeout: 0.5, callback: { (serverResponse) in
            XCTFail("PrebidServerConnection should not allow an HTTP request with invalid URL")
            self.didTalkToServerExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testHead() {
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")
        self.responseHandledExpectation = self.expectation(description: "responseHandledExpectation")
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with JSON
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: self.strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["responseHeaderKey"] = "responseHeaderVal"
        
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTAssertEqual(urlRequest.httpMethod, "HEAD")
            XCTAssertEqual(urlRequest.httpBody, nil)
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://foo.com/bo?param_key=abc123")
            let expectedRequestHeaders = [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.contentTypeKey      : PrebidServerConnection.contentTypeVal,
                PrebidServerConnection.isPBMRequestKey     : "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString
            ]
            
            let actualRequestHeaders = urlRequest.allHTTPHeaderFields!
            XCTAssertEqual(expectedRequestHeaders, actualRequestHeaders, "expected \(expectedRequestHeaders), got \(actualRequestHeaders)")
            self.didTalkToServerExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])
        
        //Test
        connection.head("http://foo.com/bo?param_key=abc123", timeout:3.0, callback:{ (serverResponse:PrebidServerResponse) in
            XCTAssertNil(serverResponse.error, "\(String(describing: serverResponse.error))")
            XCTAssertEqual(serverResponse.statusCode, 123)
            let expectedResponseHeaders = [
                "responseHeaderKey":"responseHeaderVal",
                "Content-Type":"application/json",
                "Content-Length":"\(self.strResponse.count)"
            ]
            let actualResponseHeaders = serverResponse.responseHeaders!
            XCTAssertEqual(expectedResponseHeaders, actualResponseHeaders, "Expected \(expectedResponseHeaders), got \(actualResponseHeaders)")

            //There should be no body response even if the server audaciously responds with data.
            XCTAssertNil(serverResponse.rawData)
            XCTAssertNil(serverResponse.jsonDict)
            self.responseHandledExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

    func testHEADWithInvalidURL() {
        self.didTalkToServerExpectation = unfulfilledExpectation(self, description: "didTalkToServerExpectation")

        let serverConnection = getMockedServerConnection()
        serverConnection.head(self.invalidURL, timeout: 0.5, callback: { (serverResponse) in
            XCTFail("PrebidServerConnection should not allow an HTTP request with invalid URL")
            self.didTalkToServerExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPost() {
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")
        self.responseHandledExpectation = self.expectation(description: "responseHandledExpectation")
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with JSON
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: self.strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["responseHeaderKey"] = "responseHeaderVal"
        
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.didTalkToServerExpectation.fulfill()
            XCTAssertEqual(urlRequest.httpMethod, "POST")
            XCTAssertNil(urlRequest.httpBody)
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://foo.com/bo?param_key=abc123")
            
            let expectedRequestHeaders = [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.contentTypeKey      : PrebidServerConnection.contentTypeVal,
                PrebidServerConnection.isPBMRequestKey     :  "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString,
                "Content-Length"                     : "\(self.strPostData.count)",
            ]
            let actualRequestHeaders = urlRequest.allHTTPHeaderFields!
            XCTAssertEqual(expectedRequestHeaders, actualRequestHeaders, "expected \(actualRequestHeaders), got \(actualRequestHeaders)")
        }
        MockServer.shared.resetRules([rule])
        
        let postData = strPostData.data(using: .utf8)!
        connection.post("http://foo.com/bo?param_key=abc123", data:postData, timeout:3.0, callback:{ (serverResponse:PrebidServerResponse) in
            XCTAssertNil(serverResponse.error, "\(String(describing: serverResponse.error))")
            XCTAssertEqual(serverResponse.statusCode, 123)
            let expectedResponseHeaderDict:[String:String] = [
                "responseHeaderKey":"responseHeaderVal",
                "Content-Type":"application/json",
                "Content-Length":"\(self.strResponse.count)",
            ]
            let actualResponseHeaderDict = serverResponse.responseHeaders!
            XCTAssertEqual(expectedResponseHeaderDict, actualResponseHeaderDict, "expected \(expectedResponseHeaderDict), got \(actualResponseHeaderDict)")
            
            guard let jsonDict = serverResponse.jsonDict else {
                XCTFail("jsonDict is nil")
                return
            }
            
            guard let comparableJsonDict = jsonDict as? [String:String] else {
                XCTFail("Could not cast")
                return
            }
            
            PBMAssertEq(comparableJsonDict, self.expectedJSONDict)
            self.responseHandledExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

    func testPOSTWithInvalidURL() {
        self.didTalkToServerExpectation = unfulfilledExpectation(self, description: "didTalkToServerExpectation")

        let serverConnection = getMockedServerConnection()
        serverConnection.post(self.invalidURL, data: strPostData.data(using: .utf8)!,timeout: 0.5, callback: { (serverResponse) in
            XCTFail("PrebidServerConnection should not allow an HTTP request with invalid URL")
            self.didTalkToServerExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCustomHeaders() {
        let headerField = "X-JamboJambo"
        let headerValue = "value-of-the-header-field"
        
        Prebid.shared.clearCustomHeaders()
        Prebid.shared.addCustomHeader(name: headerField, value: headerValue)
        
        self.didTalkToServerExpectation = self.expectation(description: "didTalkToServerExpectation")
        self.responseHandledExpectation = self.expectation(description: "responseHandledExpectation")
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with JSON
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: self.strResponse)
        rule.statusCode = 123
        rule.responseHeaderFields["responseHeaderKey"] = "responseHeaderVal"
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTAssertEqual(urlRequest.httpMethod, "GET")
            XCTAssertEqual(urlRequest.httpBody, nil)
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://foo.com/bo?param_key=abc123")
            
            var expectedRequestHeaders = [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.contentTypeKey      : PrebidServerConnection.contentTypeVal,
                PrebidServerConnection.isPBMRequestKey     : "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString
            ]
            
            expectedRequestHeaders.merge(dict: Prebid.shared.customHeaders)
            
            let actualRequestHeaders = urlRequest.allHTTPHeaderFields!
            XCTAssertEqual(expectedRequestHeaders, actualRequestHeaders, "expected \(expectedRequestHeaders), got \(actualRequestHeaders)")
            self.didTalkToServerExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])
        
        //Test
        connection.get("http://foo.com/bo?param_key=abc123", timeout:3.0, callback:{ (serverResponse:PrebidServerResponse) in
            XCTAssertNil(serverResponse.error, "\(String(describing: serverResponse.error))")
            XCTAssertEqual(serverResponse.statusCode, 123)

            let expectedResponseHeaders = [
                "responseHeaderKey":"responseHeaderVal",
                "Content-Type":"application/json",
                "Content-Length":"\(self.strResponse.count)"
            ]
            let actualResponseHeaders = serverResponse.responseHeaders!
            XCTAssertEqual(expectedResponseHeaders, actualResponseHeaders, "Expected \(expectedResponseHeaders), got \(actualResponseHeaders)")
            
            guard let jsonDict = serverResponse.jsonDict else {
                XCTFail("jsonDict is nil")
                return
            }
            
            guard let comparableJsonDict = jsonDict as? [String:String] else {
                XCTFail("Could not cast")
                return
            }
            
            PBMAssertEq(comparableJsonDict, self.expectedJSONDict)
            self.responseHandledExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

}

//Make a request for some arbitrary JSON and make sure it gets parsed.
class ServerConnectionTestJSON : XCTestCase {
    
    var callbackCalledExpectation:XCTestExpectation!
    
    func testJSON() {
        
        //Create a server connection
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Make a "server" that will respond with json specifying empty html as the ad content
        MockServer.shared.reset()
        let rule = MockServerRule(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: conn.internalID, fileName: "ACJEmptyHTML.json")
        rule.statusCode = 200
        MockServer.shared.resetRules([rule])

        //Run the test
        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")
        conn.post("http://foo.com", data:Data(), timeout:3.0, callback:{ (response:PrebidServerResponse) in
            self.callbackCalledExpectation.fulfill()
            XCTAssertEqual(response.statusCode, 200)

            guard let jsonDict = response.jsonDict else {
                XCTFail()
                return
            }
            
            guard let adsDict = jsonDict["ads"] as? JsonDictionary else {
                XCTFail()
                return
            }
            
            guard let adunits = adsDict["adunits"] as? [JsonDictionary] else {
                XCTFail()
                return
            }
            
            guard let adunit = adunits.first else {
                XCTFail()
                return
            }
            
            guard let chain = adunit["chain"] as? [JsonDictionary] else {
                XCTFail()
                return
            }
            
            guard let chainElement = chain.first else {
                XCTFail()
                return
            }
            
            guard let html = chainElement["html"] as? String else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(html, "<div></div>")
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }

    func testInvalidJSON() {
        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")

        let connection = getMockedServerConnection()

        let testURL = "test.com"
        let invalidJSONData = "{".data(using: .utf8)!
        let invalidJSONRule = MockServerRule(urlNeedle: testURL, mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, data: invalidJSONData)
        MockServer.shared.resetRules([invalidJSONRule])

        connection.post(testURL, data: Data(), timeout: 0.5, callback: { (serverResponse) in
            guard let error = serverResponse.error else {
                XCTFail("Invalid JSON should generate an error")
                return
            }
            XCTAssertTrue(error.localizedDescription.PBMdoesMatch("JSON Parsing Error:"))
            XCTAssertNil(serverResponse.jsonDict)

            self.callbackCalledExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValidResponseContentTypeJSON() {
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        MockServer.shared.reset()
        
        let rule = MockServerRule(
            urlNeedle: "foo.com",
            mimeType:  MockServerMimeType.JSON.rawValue,
            connectionID: connection.internalID,
            fileName: "ACJEmptyHTML.json"
        )
        
        rule.statusCode = 200
        MockServer.shared.resetRules([rule])

        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")
        
        connection.post("http://foo.com", data:Data(), timeout:3.0, callback:{ (response: PrebidServerResponse) in
            self.callbackCalledExpectation.fulfill()
            
            XCTAssertTrue(response.responseHeaders!.values.contains(MockServerMimeType.JSON.rawValue))
            
            XCTAssertNotNil(response.jsonDict)
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testValidResponseContentTypeJSONWithCharsetInfo() {
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        MockServer.shared.reset()
        
        let rule = MockServerRule(
            urlNeedle: "foo.com",
            mimeType: MockServerMimeType.jsonCharset.rawValue,
            connectionID: connection.internalID,
            fileName: "ACJEmptyHTML.json"
        )
        
        rule.statusCode = 200
        
        MockServer.shared.resetRules([rule])

        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")
        
        connection.post("http://foo.com", data:Data(), timeout:3.0, callback:{ (response: PrebidServerResponse) in
            self.callbackCalledExpectation.fulfill()
            
            XCTAssertTrue(response.responseHeaders!.values.contains(MockServerMimeType.jsonCharset.rawValue))
        
            XCTAssertNotNil(response.jsonDict)
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testInvalidResponseContentType() {
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        MockServer.shared.reset()
        
        let rule = MockServerRule(
            urlNeedle: "foo.com",
            mimeType: MockServerMimeType.XML.rawValue,
            connectionID: connection.internalID,
            data: "".data(using: .utf8)!
        )
        
        MockServer.shared.resetRules([rule])

        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")
        
        connection.post("http://foo.com", data:Data(), timeout:3.0, callback:{ (response: PrebidServerResponse) in
            self.callbackCalledExpectation.fulfill()
            
            XCTAssertTrue(response.responseHeaders!.values.contains(MockServerMimeType.XML.rawValue))
            
            XCTAssertNil(response.jsonDict)
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
}



//Make a request for some arbitrary JSON and make sure it gets parsed.
class ServerConnectionTestJSONSlow : XCTestCase {
    
    var callbackCalledExpectation:XCTestExpectation!
    
    func testJSON() {
        
        //Create a server connection
        let conn = UtilitiesForTesting.createConnectionForMockedTest()

        //MockServer that will respond with json specifying empty html as the ad content
        let rule = MockServerRuleSlow(urlNeedle: "foo.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: conn.internalID, fileName: "ACJEmptyHTML.json")
        rule.statusCode = 200
        MockServer.shared.resetRules([rule])
        
        //Run the test
        self.callbackCalledExpectation = self.expectation(description: "Expected PrebidServerConnection to fire callback")
        conn.post("http://foo.com", data:Data(), timeout:30.0, callback:{ (response:PrebidServerResponse) in
            self.callbackCalledExpectation.fulfill()
            XCTAssertEqual(response.statusCode, 200)
            
            guard let jsonDict = response.jsonDict else {
                XCTFail()
                return
            }
            
            guard let adsDict = jsonDict["ads"] as? JsonDictionary else {
                XCTFail()
                return
            }
            
            guard let adunits = adsDict["adunits"] as? [JsonDictionary] else {
                XCTFail()
                return
            }
            
            guard let adunit = adunits.first else {
                XCTFail()
                return
            }
            
            guard let chain = adunit["chain"] as? [JsonDictionary] else {
                XCTFail()
                return
            }
            
            guard let chainElement = chain.first else {
                XCTFail()
                return
            }
            
            guard let html = chainElement["html"] as? String else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(html, "<div></div>")
        })
        self.waitForExpectations(timeout: 30.0, handler: nil)
    }
    
}

class ServerConnectionTest_Redirect: XCTestCase {
    // Test how PrebidServerConnection responds to a 302 - resource moved temporarily
    // Ref: http://www.ietf.org/rfc/rfc2616.txt
    
    override func tearDown() {
        Prebid.shared.clearCustomHeaders()
    }
    
    func testServerResponse_GetReturns302() {
        
        let firstURL = "http://first.com"
        let secondURL = "http://second.com"
        let expectationFirstRuleHandled = self.expectation(description: "expectationFirstRuleHandled")
        let expectationSecondRuleHandled = self.expectation(description: "expectationSecondRuleHandled")
        let expectationResponseHandled = self.expectation(description: "expectationResponseHandled")
        let strResponse = "{\"foo\":\"bar\"}"
        let expectedJSONDict = ["foo":"bar"]
        
        let connection = getMockedServerConnection()

        //Mock a server to respond with a 302 redirect and then a real response
        MockServer.shared.reset()
        let firstRule = MockServerRuleRedirect(urlNeedle: firstURL, mimeType: MockServerMimeType.HTML.rawValue, connectionID: connection.internalID, strResponse:"")
        firstRule.redirectRequest = URLRequest(url: URL(string:secondURL)!)
        firstRule.redirectRequest?.allHTTPHeaderFields = [
            "foo":"bar",
            PrebidServerConnection.internalIDKey : connection.internalID.uuidString
        ]
        
        firstRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            PBMAssertEq(urlRequest.url?.absoluteString, firstURL)
            PBMAssertEq(urlRequest.httpMethod, "GET")
            PBMAssertEq(urlRequest.httpBody, nil)
            
            let expectedRequestHeaders = [
                PrebidServerConnection.userAgentHeaderKey  : MockUserAgentService.mockUserAgent,
                PrebidServerConnection.contentTypeKey      : PrebidServerConnection.contentTypeVal,
                PrebidServerConnection.isPBMRequestKey     : "True",
                PrebidServerConnection.internalIDKey       : connection.internalID.uuidString
            ]
            PBMAssertEq(expectedRequestHeaders, urlRequest.allHTTPHeaderFields)
            expectationFirstRuleHandled.fulfill()
        }
        
        let secondRule = MockServerRule(urlNeedle: secondURL, mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        secondRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            PBMAssertEq(urlRequest.url?.absoluteString, secondURL)
            PBMAssertEq(urlRequest.httpMethod, "GET")
            PBMAssertEq(urlRequest.httpBody, nil)
            PBMAssertEq(urlRequest.allHTTPHeaderFields, [
                "foo":"bar",
                PrebidServerConnection.internalIDKey : connection.internalID.uuidString
                ])
            
            expectationSecondRuleHandled.fulfill()
        }
        MockServer.shared.resetRules([firstRule, secondRule])
        
        // Test PrebidServerConnection
        connection.get(firstURL, timeout:3.0, callback:{ (serverResponse: PrebidServerResponse) in
            
            //The result should be that the 302 is handled internally and we get back a 200.
            PBMAssertEq(serverResponse.statusCode, 200)
            
            guard let jsonDict = serverResponse.jsonDict as? [String:String] else {
                XCTFail("Unable to cast serverResponse.jsonDict! Value was \(String(describing: serverResponse.jsonDict))")
                return
            }
            PBMAssertEq(jsonDict, expectedJSONDict)
            
            PBMAssertEq(serverResponse.error as NSError?, nil)
            
            let expectedResponseHeaders = [
                "Content-Type":"application/json",
                "Content-Length":"\(strResponse.count)"
            ]
            PBMAssertEq(serverResponse.responseHeaders, expectedResponseHeaders)
            
            expectationResponseHandled.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
}

// MARK: Utilities

/**
 *  Creates an `XCTestExpectation` that will fail if fulfilled. This is ideal in situations where
 *  test needs to validate an event does not happen.
 *
 *  - returns:
 *      An `XCTestExpectation` with `isInverted` set to `true`.
 *
 *  - parameters:
 *      - testCase: The `XCTestCase` to attach the expectation to.
 *      - description: A string to display in the test log for this expectation, to help diagnose failures.
 */
func unfulfilledExpectation(_ testCase: XCTestCase, description: String) -> XCTestExpectation {
    let expectation = testCase.expectation(description: description)
    expectation.isInverted = true

    return expectation
}

/**
 *  Creates an `PrebidServerConnection` using a `MockUserAgentService` and `MockServerURLProtocol`.
 *
 *  - returns: `PrebidServerConnection`
 */
func getMockedServerConnection() -> PrebidServerConnection {
    let serverConnection = PrebidServerConnection(userAgentService: MockUserAgentService())
    serverConnection.protocolClasses.append(MockServerURLProtocol.self)

    return serverConnection
}

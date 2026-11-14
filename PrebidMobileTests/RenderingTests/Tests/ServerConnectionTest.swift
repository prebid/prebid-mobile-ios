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
@_spi(PBMInternal) @testable import PrebidMobile

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
        assertCallsBackWithRequestError("URL creation failed") { connection, callback in
            connection.get(self.invalidURL, timeout: 0.5, callback: callback)
        }
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
        assertCallsBackWithRequestError("URL creation failed") { connection, callback in
            connection.head(self.invalidURL, timeout: 0.5, callback: callback)
        }
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
        assertCallsBackWithRequestError("URL creation failed") { connection, callback in
            connection.post(self.invalidURL, data: self.strPostData.data(using: .utf8)!, timeout: 0.5, callback: callback)
        }
    }
    
    func testDownloadWithInvalidURL() {
        assertCallsBackWithRequestError("URL creation failed") { connection, callback in
            connection.download(self.invalidURL, callback: callback)
        }
    }
    
    func testGETWithoutURL() {
        assertCallsBackWithRequestError("No resource URL string was provided") { connection, callback in
            connection.get(nil, timeout: 0.5, callback: callback)
        }
    }
    
    // No request can be sent for the URL, but the callback still runs once, with the error, so a caller
    // waiting for the response is not left waiting. Like a sent request, it calls back off the caller's thread.
    private func assertCallsBackWithRequestError(_ expectedMessage: String,
                                                 file: StaticString = #filePath, line: UInt = #line,
                                                 _ send: (PrebidServerConnection, @escaping PrebidServerResponseCallback) -> Void) {
        let callbackCalled = expectation(description: "callbackCalled")
        
        send(getMockedServerConnection()) { serverResponse in
            XCTAssertFalse(Thread.isMainThread, "The callback ran on the caller's thread", file: file, line: line)
            XCTAssertEqual(serverResponse.statusCode, 0, file: file, line: line)
            XCTAssertNil(serverResponse.rawData, file: file, line: line)
            
            let message = (serverResponse.error as? PBMError)?.message ?? ""
            XCTAssertTrue(message.hasPrefix("Invalid request: "), "Unexpected error: \(message)", file: file, line: line)
            XCTAssertTrue(message.contains(expectedMessage), "Unexpected error: \(message)", file: file, line: line)
            callbackCalled.fulfill()
        }
        
        wait(for: [callbackCalled], timeout: 1)
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
            
            guard let adsDict = jsonDict["ads"] as? [String: Any] else {
                XCTFail()
                return
            }
            
            guard let adunits = adsDict["adunits"] as? [[String: Any]] else {
                XCTFail()
                return
            }
            
            guard let adunit = adunits.first else {
                XCTFail()
                return
            }
            
            guard let chain = adunit["chain"] as? [[String: Any]] else {
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
            
            guard let adsDict = jsonDict["ads"] as? [String: Any] else {
                XCTFail()
                return
            }
            
            guard let adunits = adsDict["adunits"] as? [[String: Any]] else {
                XCTFail()
                return
            }
            
            guard let adunit = adunits.first else {
                XCTFail()
                return
            }
            
            guard let chain = adunit["chain"] as? [[String: Any]] else {
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

// The caller may release a connection while its request is in flight (`PrebidServerConnection().get(...)`).
// The callback must still fire, once.
class ServerConnectionReleasedBeforeResponseTest: XCTestCase {

    func testGetCallbackFiresAfterConnectionIsReleased() {
        assertCallbackFiresAfterConnectionIsReleased { connection, url, callback in
            connection.get(url, timeout: 10, callback: callback)
        }
    }

    func testHeadCallbackFiresAfterConnectionIsReleased() {
        assertCallbackFiresAfterConnectionIsReleased { connection, url, callback in
            connection.head(url, timeout: 10, callback: callback)
        }
    }

    func testPostCallbackFiresAfterConnectionIsReleased() {
        assertCallbackFiresAfterConnectionIsReleased { connection, url, callback in
            connection.post(url, data: Data("body".utf8), timeout: 10, callback: callback)
        }
    }

    func testDownloadCallbackFiresAfterConnectionIsReleased() {
        assertCallbackFiresAfterConnectionIsReleased { connection, url, callback in
            connection.download(url, callback: callback)
        }
    }

    // Covers the fixture: a hold released before its request starts answers the request at once and keeps no
    // reference to the protocol that loaded it.
    func testHoldReleasedBeforeTheRequestStartsAnswersAtOnce() {
        let requestStarted = XCTestExpectation(description: "The request reached the URL protocol")
        let callbackFired = XCTestExpectation(description: "The callback fired")
        let hold = HeldResponseURLProtocol.Hold(onStart: { requestStarted.fulfill() })
        let callbacks = CallbackGate()
        HeldResponseURLProtocol.register(hold)
        addTeardownBlock {
            callbacks.close()
            HeldResponseURLProtocol.unregister(hold)
        }

        hold.release()

        let connection = PrebidServerConnection(userAgentService: MockUserAgentService())
        connection.protocolClasses = [HeldResponseURLProtocol.self]
        connection.get(hold.url, timeout: 10) { response in
            callbacks.accept { count in
                XCTAssertEqual(count, 1, "The callback fired once")
                XCTAssertNil(response.error)
                XCTAssertEqual(response.statusCode, 200)
                if count == 1 {
                    callbackFired.fulfill()
                }
            }
        }

        wait(for: [requestStarted, callbackFired], timeout: 5)
        XCTAssertFalse(hold.isRetainingLoader, "The hold keeps no loader once it has answered")
    }

    private func assertCallbackFiresAfterConnectionIsReleased(
        file: StaticString = #filePath,
        line: UInt = #line,
        send: (PrebidServerConnection, String, @escaping (PrebidServerResponse) -> Void) -> Void
    ) {
        // The URL protocol holds the response until `hold.release()`. The hold's token is in the URL, so only this
        // test's request reaches this hold: a late request from another test fails at once instead.
        let requestStarted = XCTestExpectation(description: "The request reached the URL protocol")
        let callbackFired = XCTestExpectation(description: "The callback fired")
        let secondCallback = XCTestExpectation(description: "The callback fired again")
        secondCallback.isInverted = true
        let hold = HeldResponseURLProtocol.Hold(onStart: { requestStarted.fulfill() })
        let callbacks = CallbackGate()
        HeldResponseURLProtocol.register(hold)

        // Runs when the test ends, also after a failed wait. Once it has run, no callback asserts or fulfills, no
        // request can attach to the hold, and the hold no longer references a protocol.
        addTeardownBlock {
            callbacks.close()
            HeldResponseURLProtocol.unregister(hold)
        }

        weak var weakConnection: PrebidServerConnection?
        do {
            let connection = PrebidServerConnection(userAgentService: MockUserAgentService())
            connection.protocolClasses = [HeldResponseURLProtocol.self]
            weakConnection = connection
            send(connection, hold.url) { response in
                callbacks.accept { count in
                    if count == 1 {
                        XCTAssertNil(response.error, file: file, line: line)
                        XCTAssertEqual(response.statusCode, 200, file: file, line: line)
                        callbackFired.fulfill()
                    } else {
                        secondCallback.fulfill()
                    }
                }
            }
        }

        // Without a started request there is nothing to test. Releasing the hold anyway would let a late request
        // find it already released, so end the hold before returning.
        guard XCTWaiter(delegate: self).wait(for: [requestStarted], timeout: 5) == .completed else {
            callbacks.close()
            HeldResponseURLProtocol.unregister(hold)
            return
        }
        XCTAssertNil(weakConnection, "The connection is gone before the response is released", file: file, line: line)

        hold.release()
        wait(for: [callbackFired], timeout: 5)
        wait(for: [secondCallback], timeout: 0.5)
        XCTAssertFalse(hold.isRetainingLoader, "The hold keeps no loader once it has answered", file: file, line: line)
    }
}

// Counts callbacks from any thread. `accept` runs each callback's checks under the lock that `close()` takes, so
// once `close()` has returned (in the test's teardown) no callback asserts or fulfills an expectation.
private final class CallbackGate {
    private let lock = NSLock()
    private var callbacks = 0
    private var isOpen = true

    func accept(_ body: (_ count: Int) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard isOpen else {
            return
        }
        callbacks += 1
        body(callbacks)
    }

    func close() {
        lock.lock()
        isOpen = false
        lock.unlock()
    }
}

// Answers a request that has a registered hold with 200 and a small text body when its test releases the hold. It
// answers with an error instead when the hold is not released within `maximumHold`, or when the test ends first.
// A hold released before its request starts answers the request as soon as it starts. A request without a
// registered hold, a second request for the same hold, or a request after the test ended fails at once.
private final class HeldResponseURLProtocol: URLProtocol {

    static let maximumHold: TimeInterval = 10

    final class Hold {
        enum Outcome {
            case response
            case failure(Error)
        }

        let token = UUID().uuidString
        var url: String {
            "http://held.response/\(token)"
        }

        private let lock = NSLock()
        private let onStart: () -> Void
        // The protocol waiting for the outcome. Set only while the hold is unresolved; the protocol refers back to
        // the hold weakly, so clearing this is all it takes to let both go.
        private var loader: HeldResponseURLProtocol?
        private var outcome: Outcome?
        private var hasStarted = false
        private var hasEnded = false

        init(onStart: @escaping () -> Void) {
            self.onStart = onStart
        }

        /// Whether the hold still references the protocol that loads its request.
        var isRetainingLoader: Bool {
            lock.lock()
            defer { lock.unlock() }
            return loader != nil
        }

        /// Called by the URL protocol that loads the request. Returns false when the protocol must fail the request.
        fileprivate func attach(_ loader: HeldResponseURLProtocol) -> Bool {
            lock.lock()
            guard !hasEnded, !hasStarted else {
                lock.unlock()
                return false
            }
            hasStarted = true
            // Under the lock, so the test cannot end between the check above and this call.
            onStart()
            if let outcome {
                // Resolved before the request started: answer at once and keep no reference to the protocol.
                lock.unlock()
                loader.answer(outcome)
                return true
            }
            self.loader = loader
            lock.unlock()

            DispatchQueue.global().asyncAfter(deadline: .now() + HeldResponseURLProtocol.maximumHold) { [weak self] in
                self?.resolve(.failure(URLError(.timedOut)))
            }
            return true
        }

        /// Lets the protocol answer with the response.
        func release() {
            resolve(.response)
        }

        /// Called when the URL loading system stops the request: there is nobody to answer any more.
        fileprivate func detach(_ loader: HeldResponseURLProtocol) {
            lock.lock()
            if self.loader === loader {
                self.loader = nil
                if outcome == nil {
                    outcome = .failure(URLError(.cancelled))
                }
            }
            lock.unlock()
        }

        /// The test ended: no request may attach any more, and the hold lets go of its protocol even if the
        /// protocol's thread never runs the cancellation it is sent.
        fileprivate func end() {
            lock.lock()
            hasEnded = true
            lock.unlock()
            resolve(.failure(URLError(.cancelled)))
        }

        // Only the first outcome counts. The protocol waiting for it, if any, gets it once and is let go.
        private func resolve(_ outcome: Outcome) {
            lock.lock()
            guard self.outcome == nil else {
                lock.unlock()
                return
            }
            self.outcome = outcome
            let loader = self.loader
            self.loader = nil
            lock.unlock()
            loader?.answer(outcome)
        }
    }

    private static let registryLock = NSLock()
    private static var holds = [String: Hold]()

    static func register(_ hold: Hold) {
        registryLock.lock()
        holds[hold.token] = hold
        registryLock.unlock()
    }

    static func unregister(_ hold: Hold) {
        registryLock.lock()
        holds[hold.token] = nil
        registryLock.unlock()
        hold.end()
    }

    private static func hold(for request: URLRequest) -> Hold? {
        guard let token = request.url?.lastPathComponent else {
            return nil
        }
        registryLock.lock()
        defer { registryLock.unlock() }
        return holds[token]
    }

    // The thread and run loop mode that started loading: URLProtocol clients expect calls there.
    private var clientThread: Thread?
    private var clientModes = [RunLoop.Mode.default.rawValue]
    private weak var hold: Hold?
    private var isStopped = false

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        clientThread = Thread.current
        if let mode = RunLoop.current.currentMode, mode != .default {
            clientModes.append(mode.rawValue)
        }
        guard let hold = Self.hold(for: request), hold.attach(self) else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }
        self.hold = hold
    }

    override func stopLoading() {
        isStopped = true
        hold?.detach(self)
    }

    fileprivate func answer(_ outcome: Hold.Outcome) {
        guard let clientThread else {
            return
        }
        perform(#selector(deliver(_:)), on: clientThread, with: OutcomeBox(outcome), waitUntilDone: false,
                modes: clientModes)
    }

    @objc private func deliver(_ box: OutcomeBox) {
        guard !isStopped else {
            return
        }
        switch box.outcome {
        case .response:
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1",
                                                 headerFields: ["Content-Type": "text/plain"]) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data("held".utf8))
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    private final class OutcomeBox: NSObject {
        let outcome: Hold.Outcome

        init(_ outcome: Hold.Outcome) {
            self.outcome = outcome
        }
    }
}

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

/*   Copyright 2018-2025 Prebid.org, Inc.

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

@_spi(PBMInternal) @testable import PrebidMobile

class VastRequesterTest: XCTestCase {

    private func makeResponse(statusCode: Int, rawData: Data? = nil, error: Error? = nil) -> PrebidServerResponse {
        let response = PrebidServerResponse()
        response.statusCode = statusCode
        response.rawData = rawData
        response.error = error
        return response
    }

    private func load(url: String?, response: PrebidServerResponse?) -> (response: PrebidServerResponse?, error: Error?, postCalled: Bool) {
        var postCalled = false
        let connection = MockServerConnection(onPost: [{ (_, contentType, _, _, callback) in
            postCalled = true
            XCTAssertEqual(contentType, "application/x-www-form-urlencoded")
            if let response {
                callback(response)
            }
        }])

        var result: (PrebidServerResponse?, Error?) = (nil, nil)
        let exp = expectation(description: "completion")
        VastRequester.loadVastURL(url, connection: connection) { serverResponse, error in
            result = (serverResponse, error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
        return (result.0, result.1, postCalled)
    }

    func testSuccess() {
        let response = makeResponse(statusCode: 200, rawData: Data("<VAST/>".utf8))
        let (serverResponse, error, postCalled) = load(url: "https://example.com/vast?a=1", response: response)
        XCTAssertTrue(postCalled)
        XCTAssertNil(error)
        XCTAssertTrue(serverResponse === response)
    }

    func testConnectionError() {
        let connectionError = NSError(domain: "test", code: 5)
        let (serverResponse, error, _) = load(url: "https://example.com/vast",
                                              response: makeResponse(statusCode: 200, error: connectionError))
        XCTAssertNil(serverResponse)
        XCTAssertEqual(error as NSError?, connectionError)
    }

    func testNon200Status() {
        let (serverResponse, error, _) = load(url: "https://example.com/vast",
                                              response: makeResponse(statusCode: 404, rawData: Data()))
        XCTAssertNil(serverResponse)
        XCTAssertEqual((error as NSError?)?.code, 404)
        XCTAssertEqual((error as? PBMError)?.message, "Server responded with status code 404")
    }

    func testNoData() {
        let (serverResponse, error, _) = load(url: "https://example.com/vast",
                                              response: makeResponse(statusCode: 200))
        XCTAssertNil(serverResponse)
        XCTAssertEqual((error as NSError?)?.code, PBMErrorCode.fileNotFound.rawValue)
    }

    func testInvalidURLFailsWithoutPosting() {
        let (serverResponse, error, postCalled) = load(url: nil, response: nil)
        XCTAssertFalse(postCalled)
        XCTAssertNil(serverResponse)
        XCTAssertEqual((error as NSError?)?.code, PBMErrorCode.undefined.rawValue)
    }
}

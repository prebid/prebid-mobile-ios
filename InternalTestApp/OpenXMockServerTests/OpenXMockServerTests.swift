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

import Combine
import XCTest
@testable import OpenXMockServer

class OpenXMockServerTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        cancellables.removeAll()
        session.invalidateAndCancel()
        MockURLProtocol.response = nil
        super.tearDown()
    }

    func testGetEncodesParametersAndRetainsEndpointQuery() throws {
        let endpoint = ApiEndpoint(path: "logs", queryItems: ["existing": "value"])
        let request = MockServerManager.request(method: .get, endpoint: endpoint, parameters: ["mock": "a+b &c=1/#"], headers: ["X-Test": "yes"])
        let components = try XCTUnwrap(URLComponents(url: XCTUnwrap(request.url), resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, ApiEndpoint.host)
        XCTAssertEqual(components.port, ApiEndpoint.port)
        XCTAssertEqual(components.path, "/api/logs")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "existing", value: "value"), URLQueryItem(name: "mock", value: "a+b &c=1/#")])
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "yes")
    }

    func testPostFormEncodesReservedCharactersInBody() {
        let request = MockServerManager.request(method: .post, endpoint: .addMock(), parameters: ["mock": "a+b &c=1/#", "auid": "test"], headers: [:])
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNil(request.url?.query)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(request.httpBody.flatMap { String(data: $0, encoding: .utf8) }, "auid=test&mock=a%2Bb%20%26c%3D1%2F%23")
    }

    func testSuccessfulResponseDecodesAndDeliversOnMainThread() {
        respond(status: 200, body: #"{"result":true}"#)
        let done = expectation(description: "Decoded response")
        let publisher: AnyPublisher<AddMockResponse, Error> = MockServerManager(session: session).makeRequestWithParsing(method: .post, endpoint: .addMock())
        publisher.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion { XCTFail("Unexpected error: \(error)") }
        }, receiveValue: { response in
            XCTAssertTrue(response.result)
            XCTAssertTrue(Thread.isMainThread)
            done.fulfill()
        }).store(in: &cancellables)
        waitForExpectations(timeout: 3)
    }

    func testNonSuccessStatusFailsBeforeDecoding() {
        respond(status: 503, body: "invalid JSON")
        let done = expectation(description: "HTTP error")
        let publisher: AnyPublisher<AddMockResponse, Error> = MockServerManager(session: session).makeRequestWithParsing(method: .get, endpoint: .getLogs())
        publisher.sink(receiveCompletion: { completion in
            guard case .failure(NetworkError.unexpectedHttpError(let code)) = completion else {
                XCTFail("Expected HTTP error, got \(completion)")
                done.fulfill()
                return
            }
            XCTAssertEqual(code, 503)
            done.fulfill()
        }, receiveValue: { _ in XCTFail("Unexpected response") }).store(in: &cancellables)
        waitForExpectations(timeout: 3)
    }

    func testUndecodableBodyCompletesWithoutValue() {
        respond(status: 200, body: "invalid JSON")
        let done = expectation(description: "Empty completion")
        let publisher: AnyPublisher<AddMockResponse, Error> = MockServerManager(session: session).makeRequestWithParsing(method: .get, endpoint: .getLogs())
        publisher.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion { XCTFail("Unexpected error: \(error)") }
            done.fulfill()
        }, receiveValue: { _ in XCTFail("Unexpected response") }).store(in: &cancellables)
        waitForExpectations(timeout: 3)
    }

    func testOfflineErrorKeepsNoConnectionContract() {
        MockURLProtocol.response = { _ in throw URLError(.notConnectedToInternet) }
        let done = expectation(description: "Offline error")
        let publisher: AnyPublisher<AddMockResponse, Error> = MockServerManager(session: session).makeRequestWithParsing(method: .get, endpoint: .getLogs())
        publisher.sink(receiveCompletion: { completion in
            guard case .failure(NetworkError.noConnection) = completion else {
                XCTFail("Expected noConnection, got \(completion)")
                done.fulfill()
                return
            }
            done.fulfill()
        }, receiveValue: { _ in XCTFail("Unexpected response") }).store(in: &cancellables)
        waitForExpectations(timeout: 3)
    }

    private func respond(status: Int, body: String) {
        MockURLProtocol.response = { request in
            (HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!, Data(body.utf8))
        }
    }
}

private final class MockURLProtocol: URLProtocol {
    static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (response, data) = try Self.response!(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}

/*   Copyright 2018-2026 Prebid.org, Inc.

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

final class ImageHelperTests: XCTestCase {

    private var session: URLSession!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageHelperURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        session.invalidateAndCancel()
        session = nil
        ImageHelperURLProtocol.requestHandler = nil

        super.tearDown()
    }

    func testDownloadImageAsyncReturnsImageOnMainThread() {
        let imageData = Data(base64Encoded:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
        )!

        ImageHelperURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "image/png"]
                )!,
                imageData
            )
        }

        let expectation = expectation(description: "Image completion")

        ImageHelper.downloadImageAsync(
            "https://example.com/image.png",
            session: session
        ) { result in
            XCTAssertTrue(Thread.isMainThread)

            guard case .success = result else {
                XCTFail("Expected image download to succeed")
                expectation.fulfill()
                return
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testDownloadImageAsyncReturnsNetworkFailureOnMainThread() {
        ImageHelperURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let expectation = expectation(description: "Network failure completion")

        ImageHelper.downloadImageAsync(
            "https://example.com/image.png",
            session: session
        ) { result in
            XCTAssertTrue(Thread.isMainThread)

            guard case .failure = result else {
                XCTFail("Expected image download to fail")
                expectation.fulfill()
                return
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testDownloadImageAsyncReturnsInvalidImageFailureOnMainThread() {
        ImageHelperURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "text/plain"]
                )!,
                Data("not an image".utf8)
            )
        }

        let expectation = expectation(description: "Invalid image completion")

        ImageHelper.downloadImageAsync(
            "https://example.com/image.png",
            session: session
        ) { result in
            XCTAssertTrue(Thread.isMainThread)

            guard case .failure = result else {
                XCTFail("Expected invalid image data to fail")
                expectation.fulfill()
                return
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testDownloadImageAsyncReturnsInvalidURLFailureAsynchronouslyOnMainThread() {
        let expectation = expectation(description: "Invalid URL completion")
        var completionCalled = false

        ImageHelper.downloadImageAsync("http://[invalid") { result in
            completionCalled = true
            XCTAssertTrue(Thread.isMainThread)

            guard case .failure = result else {
                XCTFail("Expected invalid URL to fail")
                expectation.fulfill()
                return
            }

            expectation.fulfill()
        }

        XCTAssertFalse(completionCalled)
        waitForExpectations(timeout: 1)
    }
}

private final class ImageHelperURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

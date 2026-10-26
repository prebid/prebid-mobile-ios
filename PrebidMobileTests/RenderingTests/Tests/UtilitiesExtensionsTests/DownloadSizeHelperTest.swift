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

class DownloadSizeHelperTest: XCTestCase {
    private var connection: PrebidServerConnection!
    private let url = URL(string: "http://download-size.test/video")!
    private let requestLock = NSLock()
    private var recordedMethods = [String]()

    override func setUp() {
        super.setUp()
        MockServer.shared.reset()
        connection = UtilitiesForTesting.createConnectionForMockedTest()
    }

    override func tearDown() {
        MockServer.shared.reset()
        connection = nil
        recordedMethods = []
        super.tearDown()
    }

    // DownloadDataHelper handles bytes and headers, not video decoding. Small
    // in-memory bodies cover its contract without transferring a 58 MB fixture
    // within the same two-second deadline on a three-core CI runner.
    func testUnrestrictedDownloadReturnsExactBytes() {
        let body = Data((0..<255).map { UInt8($0) })
        serve(body)
        let result = download()
        XCTAssertEqual(result.data, body)
        XCTAssertNil(result.error)
        XCTAssertEqual(requestMethods, ["GET"])
    }

    func testUnrestrictedDownloadReturnsEmptyBody() {
        serve(Data())
        let result = download()
        XCTAssertEqual(result.data, Data())
        XCTAssertNil(result.error)
    }

    func testBodyBelowLimitIsDownloaded() {
        assertBodyIsDownloaded(size: 9, limit: 10)
    }

    func testBodyAtLimitIsDownloaded() {
        assertBodyIsDownloaded(size: 10, limit: 10)
    }

    func testBodyAboveLimitIsRejectedWithoutDownload() {
        serve(Data(repeating: 1, count: 11))
        let result = download(maxSize: 10)
        XCTAssertNil(result.data)
        XCTAssertTrue(result.error?.localizedDescription.contains("greater than the maximum size") == true)
        XCTAssertEqual(requestMethods, ["HEAD"])
    }

    func testMissingContentLengthIsRejectedWithoutDownload() {
        let rule = serve(Data(repeating: 1, count: 5))
        rule.responseHeaderFields.removeObject(forKey: "Content-Length")
        assertInvalidContentLengthIsRejected()
    }

    func testMalformedContentLengthIsRejectedWithoutDownload() {
        let rule = serve(Data(repeating: 1, count: 5))
        rule.responseHeaderFields["Content-Length"] = "invalid"
        assertInvalidContentLengthIsRejected()
    }

    func testNegativeContentLengthIsRejectedWithoutDownload() {
        let rule = serve(Data(repeating: 1, count: 5))
        rule.responseHeaderFields["Content-Length"] = "-1"
        assertInvalidContentLengthIsRejected()
    }

    private var requestMethods: [String] {
        requestLock.lock()
        defer { requestLock.unlock() }
        return recordedMethods
    }

    @discardableResult
    private func serve(_ body: Data) -> MockServerRule {
        let rule = MockServerRule(urlNeedle: url.absoluteString,
                                  mimeType: MockServerMimeType.MP4.rawValue,
                                  connectionID: connection.internalID, data: body)
        rule.mockServerReceivedRequestHandler = { [weak self] request in
            guard let self else { return }
            self.requestLock.lock()
            self.recordedMethods.append(request.httpMethod ?? "")
            self.requestLock.unlock()
        }
        MockServer.shared.resetRules([rule])
        return rule
    }

    private func download(maxSize: Int? = nil) -> (data: Data?, error: Error?) {
        let finished = expectation(description: "Download completed")
        finished.assertForOverFulfill = true
        var result: (data: Data?, error: Error?) = (nil, nil)
        let completion: (Data?, Error?) -> Void = { data, error in
            result = (data, error)
            finished.fulfill()
        }
        let helper = DownloadDataHelper(serverConnection: connection)
        if let maxSize {
            helper.downloadData(for: url, maxSize: maxSize, completionClosure: completion)
        } else {
            helper.downloadData(for: url, completionClosure: completion)
        }
        wait(for: [finished], timeout: 2)
        return result
    }

    private func assertBodyIsDownloaded(size: Int, limit: Int, file: StaticString = #filePath, line: UInt = #line) {
        let body = Data(repeating: 1, count: size)
        serve(body)
        let result = download(maxSize: limit)
        XCTAssertEqual(result.data, body, file: file, line: line)
        XCTAssertNil(result.error, file: file, line: line)
        XCTAssertEqual(requestMethods, ["HEAD", "GET"], file: file, line: line)
    }

    private func assertInvalidContentLengthIsRejected(file: StaticString = #filePath, line: UInt = #line) {
        let result = download(maxSize: 10)
        XCTAssertNil(result.data, file: file, line: line)
        XCTAssertTrue(result.error?.localizedDescription.contains("Unable to determine video file size") == true, file: file, line: line)
        XCTAssertEqual(requestMethods, ["HEAD"], file: file, line: line)
    }
}

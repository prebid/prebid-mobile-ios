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

// A wrapper response that keeps two or more wrapper ads: the load has to wait for every one of them
// and complete exactly once, whatever order their responses come back in.
class VastAdsBuilderWrapperTest: XCTestCase {

    private typealias BuildResult = (ads: [VastAbstractAd]?, error: Error?)

    private var connection: DeferredVastConnection!
    private var builder: VastAdsBuilder!
    private var results: [BuildResult] = []

    override func setUp() {
        super.setUp()
        connection = DeferredVastConnection()
        builder = VastAdsBuilder(connection: connection)
        results = []
    }

    override func tearDown() {
        connection = nil
        builder = nil
        results = []
        super.tearDown()
    }

    func testTwoChildWrappers_completesOnceWithBothAds() {
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B1", uri: "https://example.com/b1"),
                                          wrapperAd("B2", uri: "https://example.com/b2")),
            "https://example.com/b1": inlineDocument(),
            "https://example.com/b2": inlineDocument(),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a", wrapperAttributes: #" allowMultipleAds="true""#)))

        connection.respond(to: "https://example.com/a")
        connection.respond(to: "https://example.com/b1")
        XCTAssertTrue(results.isEmpty, "Completed before the second child wrapper resolved")

        connection.respond(to: "https://example.com/b2")
        assertCompletedOnce(adCount: 2)
    }

    func testThreeChildWrappers_waitsForTheLastResponse() {
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B1", uri: "https://example.com/b1"),
                                          wrapperAd("B2", uri: "https://example.com/b2"),
                                          wrapperAd("B3", uri: "https://example.com/b3")),
            "https://example.com/b1": inlineDocument(),
            "https://example.com/b2": inlineDocument(),
            "https://example.com/b3": inlineDocument(),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a", wrapperAttributes: #" allowMultipleAds="true""#)))

        connection.respond(to: "https://example.com/a")
        connection.respond(to: "https://example.com/b1")
        connection.respond(to: "https://example.com/b3")
        XCTAssertTrue(results.isEmpty, "Completed while the middle child wrapper was still pending")

        connection.respond(to: "https://example.com/b2")
        assertCompletedOnce(adCount: 3)
    }

    func testChildWrappersWithNonZeroSequence_completesOnceWithBothAds() {
        // Without allowMultipleAds the response keeps every ad when none of them has sequence 0.
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B1", uri: "https://example.com/b1", adAttributes: #" sequence="1""#),
                                          wrapperAd("B2", uri: "https://example.com/b2", adAttributes: #" sequence="2""#)),
            "https://example.com/b1": inlineDocument(),
            "https://example.com/b2": inlineDocument(),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a")))

        connection.respond(to: "https://example.com/a")
        connection.respond(to: "https://example.com/b2")
        XCTAssertTrue(results.isEmpty, "Completed before the first child wrapper resolved")

        connection.respond(to: "https://example.com/b1")
        assertCompletedOnce(adCount: 2)
    }

    func testRootWrappersWithOneChildWrapperEach_completesOnceWithBothAds() {
        connection.documents = [
            "https://example.com/a1": vast(wrapperAd("C1", uri: "https://example.com/c1")),
            "https://example.com/a2": vast(wrapperAd("C2", uri: "https://example.com/c2")),
            "https://example.com/c1": inlineDocument(),
            "https://example.com/c2": inlineDocument(),
        ]

        build(vast(wrapperAd("A1", uri: "https://example.com/a1"),
                   wrapperAd("A2", uri: "https://example.com/a2")))

        connection.respond(to: "https://example.com/a1")
        connection.respond(to: "https://example.com/a2")
        connection.respond(to: "https://example.com/c1")
        XCTAssertTrue(results.isEmpty, "Completed before the second chain resolved")

        connection.respond(to: "https://example.com/c2")
        assertCompletedOnce(adCount: 2)
    }

    func testWrapperChain_completesOnceWithTheAd() {
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B", uri: "https://example.com/b")),
            "https://example.com/b": vast(wrapperAd("C", uri: "https://example.com/c")),
            "https://example.com/c": inlineDocument(),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a")))

        connection.respond(to: "https://example.com/a")
        connection.respond(to: "https://example.com/b")
        XCTAssertTrue(results.isEmpty)

        connection.respond(to: "https://example.com/c")
        assertCompletedOnce(adCount: 1)
    }

    func testInlineRoot_completesOnceWithoutRequests() {
        build(inlineDocument())

        XCTAssertTrue(connection.requestedURLs.isEmpty)
        assertCompletedOnce(adCount: 1)
    }

    func testChildWrapperFailure_completesOnceWithTheError() {
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B1", uri: "https://example.com/b1"),
                                          wrapperAd("B2", uri: "https://example.com/b2")),
            "https://example.com/b2": inlineDocument(),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a", wrapperAttributes: #" allowMultipleAds="true""#)))

        connection.respond(to: "https://example.com/a")
        let failure = NSError(domain: "test", code: 1)
        connection.respond(to: "https://example.com/b1", error: failure)

        XCTAssertEqual(results.count, 1)
        XCTAssertNil(results.first?.ads)
        XCTAssertEqual(results.first?.error as NSError?, failure)

        // A sibling that resolves after the failure does not complete the load again.
        connection.respond(to: "https://example.com/b2")
        XCTAssertEqual(results.count, 1)
    }

    func testTwoChildWrapperFailures_completeOnce() {
        connection.documents = [
            "https://example.com/a": vast(wrapperAd("B1", uri: "https://example.com/b1"),
                                          wrapperAd("B2", uri: "https://example.com/b2")),
        ]

        build(vast(wrapperAd("A", uri: "https://example.com/a", wrapperAttributes: #" allowMultipleAds="true""#)))

        connection.respond(to: "https://example.com/a")
        connection.respond(to: "https://example.com/b1", error: NSError(domain: "test", code: 1))
        connection.respond(to: "https://example.com/b2", error: NSError(domain: "test", code: 2))

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual((results.first?.error as NSError?)?.code, 1)
    }

    // MARK: - Helpers

    private func build(_ rootDocument: Data) {
        builder.buildAds(rootDocument) { [weak self] ads, error in
            self?.results.append((ads, error))
        }
    }

    private func assertCompletedOnce(adCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(results.count, 1, "Expected exactly one completion", file: file, line: line)
        XCTAssertNil(results.first?.error, file: file, line: line)
        XCTAssertEqual(results.first?.ads?.count, adCount, file: file, line: line)
        XCTAssertTrue(connection.pendingURLs.isEmpty, "Requests still pending: \(connection.pendingURLs)", file: file, line: line)
    }

    private func wrapperAd(_ id: String, uri: String, adAttributes: String = "", wrapperAttributes: String = "") -> String {
        """
        <Ad id="\(id)"\(adAttributes)><Wrapper\(wrapperAttributes)>\
        <AdSystem>S</AdSystem>\
        <VASTAdTagURI><![CDATA[\(uri)]]></VASTAdTagURI>\
        <Impression><![CDATA[https://example.com/imp/\(id)]]></Impression>\
        </Wrapper></Ad>
        """
    }

    private func vast(_ ads: String...) -> Data {
        Data(#"<VAST version="3.0">\#(ads.joined())</VAST>"#.utf8)
    }

    private func inlineDocument() -> Data {
        UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_inline_ad.xml")!
    }
}

// Serves VAST documents by URL and holds each GET until the test answers it, so the test sets the order
// in which wrapper responses arrive.
private final class DeferredVastConnection: NSObject, PrebidServerConnectionProtocol {

    let userAgentService = UserAgentService.shared

    var documents: [String: Data] = [:]
    private(set) var requestedURLs: [String] = []
    private var callbacks: [String: PrebidServerResponseCallback] = [:]

    var pendingURLs: [String] {
        callbacks.keys.sorted()
    }

    func respond(to url: String, error: Error? = nil, file: StaticString = #filePath, line: UInt = #line) {
        guard let callback = callbacks.removeValue(forKey: url) else {
            XCTFail("No pending request for \(url)", file: file, line: line)
            return
        }

        let response = PrebidServerResponse()
        if let error {
            response.error = error
        } else {
            response.statusCode = 200
            response.rawData = documents[url]
        }
        callback(response)
    }

    func get(_ resourceURL: String?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback) {
        guard let resourceURL else {
            XCTFail("GET without a URL")
            return
        }
        requestedURLs.append(resourceURL)
        callbacks[resourceURL] = callback
    }

    func fireAndForget(_ resourceURL: String?) {}

    func head(_ resourceURL: String?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback) {
        XCTFail("Unexpected HEAD \(resourceURL ?? "nil")")
    }

    func post(_ resourceURL: String?, data: Data?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback) {
        XCTFail("Unexpected POST \(resourceURL ?? "nil")")
    }

    func post(_ resourceURL: String?, contentType: String?, data: Data?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback) {
        XCTFail("Unexpected POST \(resourceURL ?? "nil")")
    }

    func download(_ resourceURL: String?, callback: @escaping PrebidServerResponseCallback) {
        XCTFail("Unexpected download \(resourceURL ?? "nil")")
    }
}

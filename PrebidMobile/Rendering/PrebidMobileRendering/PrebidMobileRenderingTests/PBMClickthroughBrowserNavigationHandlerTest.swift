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
import WebKit

class PBMClickthroughBrowserNavigationHandlerTest: XCTestCase {
    private var mockWebView: MockWebView!
    private var navigationHandler: PBMClickthroughBrowserNavigationHandler!
    
    override func tearDown() {
        mockWebView = nil
        navigationHandler = nil
        PBMDeepLinkPlusHelper.application = nil
        PBMDeepLinkPlusHelper.connection = PBMServerConnection.singleton()
    }
    
    private enum SomeError: Error {
        case whatever
    }
    
    private let someHttpLink = "http://google.com"
    private let otherHttpLink = "http://duckduckgo.com"
    private let deepLinkHttpFallback =  "deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=http%3A%2F%2Fmobile.twitter.com&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fclicktracking&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fmopubtracking"
    private let deepLinkDeepFallback =  "deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=app-settings%3A&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fclicktracking&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fmopubtracking"
    
    let primaryTrackingURLStrings = ["http://mopub.com/clicktracking", "http://mopub.com/mopubtracking"]
    let fallbackTrackingURLStrings = ["http://mopub.net/clicktracking", "http://mopub.net/mopubtracking"]
    
    let primaryDeepScheme = "twitter"
    let fallbackDeepScheme = "app-settings"
    
    let primaryDeepLink = "twitter://timeline"
    let fallbackHttpLink = "http://mobile.twitter.com"
    let fallbackDeepLink = "app-settings:"
    
    // MARK: - TESTS
    
    // MARK: + simple HTTP
    
    func testOpenNormalURL_Ok() {
        guard let link = URL(string: someHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didCommit: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertTrue(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenNormalURL_Fail() {
        guard let link = URL(string: someHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didFail: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenNormalURL_FailProvisional() {
        guard let link = URL(string: someHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: + deeplink+
    
    func testOpenDeepLink_PrimaryOK() {
        guard let link = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return true
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [primaryTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, primaryTrackingURLStrings[0])
                },
                { [primaryTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, primaryTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenDeepStarted = expectation(description: "urlOpenDeepStarted")
        let urlDecisionResult = expectation(description: "urlDecisionResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.deepLinkHttpFallback))
                    urlOpenDeepStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .cancel)
                        urlDecisionResult.fulfill()
                        self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testOpenDeepLink_FallbackHttpOk() {
        guard let link = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return false
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenDeepStarted = expectation(description: "urlOpenDeepStarted")
        let urlDecisionResult = expectation(description: "urlDecisionResult")
        
        let urlOpenHttpStarted = expectation(description: "urlOpenHttpStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.deepLinkHttpFallback))
                    urlOpenDeepStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .cancel)
                        urlDecisionResult.fulfill()
                        self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    }
                    return nil
                },
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.fallbackHttpLink))
                    urlOpenHttpStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didCommit: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertTrue(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenDeepLink_FallbackHttpFail() {
        guard let link = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return false
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenDeepStarted = expectation(description: "urlOpenDeepStarted")
        let urlDecisionResult = expectation(description: "urlDecisionResult")
        
        let urlOpenHttpStarted = expectation(description: "urlOpenHttpStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.deepLinkHttpFallback))
                    urlOpenDeepStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .cancel)
                        urlDecisionResult.fulfill()
                        self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    }
                    return nil
                },
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.fallbackHttpLink))
                    urlOpenHttpStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didFail: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenDeepLink_FallbackDeepOk() {
        guard let link = URL(string: deepLinkDeepFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let checkCanOpenPrimaryScheme = expectation(description: "checkCanOpenPrimaryScheme")
        let checkCanOpenFallbackScheme = expectation(description: "checkCanOpenFallbackScheme")
        
        var primarySchemeChecked = false
        var fallbackSchemeChecked = false
        
        mockApplication.openURLClosure = { [primaryDeepScheme, fallbackDeepScheme] url in
            switch url.scheme {
            case primaryDeepScheme:
                XCTAssertFalse(primarySchemeChecked)
                primarySchemeChecked = true
                checkCanOpenPrimaryScheme.fulfill()
                return false
            case fallbackDeepScheme:
                XCTAssertFalse(fallbackSchemeChecked)
                fallbackSchemeChecked = true
                checkCanOpenFallbackScheme.fulfill()
                return true
            default:
                XCTFail("Attempting to open unexpected scheme: \(String(describing: url.scheme))")
                return false
            }
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenDeepStarted = expectation(description: "urlOpenDeepStarted")
        let urlDecisionResult = expectation(description: "urlDecisionResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    urlOpenDeepStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .cancel)
                        urlDecisionResult.fulfill()
                        self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenDeepLink_FallbackDeepFail() {
        guard let link = URL(string: deepLinkDeepFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let checkCanOpenPrimaryScheme = expectation(description: "checkCanOpenPrimaryScheme")
        let checkCanOpenFallbackScheme = expectation(description: "checkCanOpenFallbackScheme")
        
        var primarySchemeChecked = false
        var fallbackSchemeChecked = false
        
        mockApplication.openURLClosure = { [primaryDeepScheme, fallbackDeepScheme] url in
            switch url.scheme {
            case primaryDeepScheme:
                XCTAssertFalse(primarySchemeChecked)
                primarySchemeChecked = true
                checkCanOpenPrimaryScheme.fulfill()
                return false
            case fallbackDeepScheme:
                XCTAssertFalse(fallbackSchemeChecked)
                fallbackSchemeChecked = true
                checkCanOpenFallbackScheme.fulfill()
                return false
            default:
                XCTFail("Attempting to open unexpected scheme: \(String(describing: url.scheme))")
                return false
            }
        }
        
        let mockConnection = MockServerConnection()
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenDeepStarted = expectation(description: "urlOpenDeepStarted")
        let urlDecisionDeepResult = expectation(description: "urlDecisionDeepResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.deepLinkDeepFallback))
                    urlOpenDeepStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .cancel)
                        urlDecisionDeepResult.fulfill()
                        self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: + redirect HTTP -> HTTP
    
    func testOpenRedirectURL_Http_Ok() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: otherHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .allow)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didCommit: nil)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertTrue(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenRedirectURL_Http_Fail() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: otherHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .allow)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFail: nil)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenRedirectURL_Http_FailProvisionsal() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: otherHttpLink) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .allow)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: + redirect HTTP -> deeplink+
    
    func testOpenRedirectURL_DeepLink_PrimaryOK() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return true
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [primaryTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, primaryTrackingURLStrings[0])
                },
                { [primaryTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, primaryTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .cancel)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testOpenRedirectURL_DeepLink_FallbackHttpOk() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return false
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        let urlOpenHttpStarted = expectation(description: "urlOpenHttpStarted")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .cancel)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                },
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.fallbackHttpLink))
                    urlOpenHttpStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didCommit: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertTrue(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenRedirectURL_DeepLink_FallbackHttpFail() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: deepLinkHttpFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let openPrimaryDeepRequested = expectation(description: "openPrimaryDeepRequested")
        
        mockApplication.openURLClosure = { [primaryDeepLink] url in
            XCTAssertEqual(url, URL(string: primaryDeepLink))
            openPrimaryDeepRequested.fulfill()
            return false
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenHttpStarted = expectation(description: "urlOpenHttpStarted")
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .cancel)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                },
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.fallbackHttpLink))
                    urlOpenHttpStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, didFail: nil)
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenRedirectURL_DeepLink_FallbackDeepOk() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: deepLinkDeepFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let checkCanOpenPrimaryScheme = expectation(description: "checkCanOpenPrimaryScheme")
        let checkCanOpenFallbackScheme = expectation(description: "checkCanOpenFallbackScheme")
        
        var primarySchemeChecked = false
        var fallbackSchemeChecked = false
        
        mockApplication.openURLClosure = { [primaryDeepScheme, fallbackDeepScheme] url in
            switch url.scheme {
            case primaryDeepScheme:
                XCTAssertFalse(primarySchemeChecked)
                primarySchemeChecked = true
                checkCanOpenPrimaryScheme.fulfill()
                return false
            case fallbackDeepScheme:
                XCTAssertFalse(fallbackSchemeChecked)
                fallbackSchemeChecked = true
                checkCanOpenFallbackScheme.fulfill()
                return true
            default:
                XCTFail("Attempting to open unexpected scheme: \(String(describing: url.scheme))")
                return false
            }
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[0])
                },
                { [fallbackTrackingURLStrings] (url, timeout, callback) in
                    XCTAssertEqual(url, fallbackTrackingURLStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .cancel)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOpenRedirectURL_DeepLink_FallbackDeepFail() {
        guard let link = URL(string: someHttpLink), let otherLink = URL(string: deepLinkDeepFallback) else {
            XCTFail("Failed to parse link URL")
            return
        }
        
        let mockApplication = MockUIApplication()
        
        let checkCanOpenPrimaryScheme = expectation(description: "checkCanOpenPrimaryScheme")
        let checkCanOpenFallbackScheme = expectation(description: "checkCanOpenFallbackScheme")
        
        var primarySchemeChecked = false
        var fallbackSchemeChecked = false
        
        mockApplication.openURLClosure = { [primaryDeepScheme, fallbackDeepScheme] url in
            switch url.scheme {
            case primaryDeepScheme:
                XCTAssertFalse(primarySchemeChecked)
                primarySchemeChecked = true
                checkCanOpenPrimaryScheme.fulfill()
                return false
            case fallbackDeepScheme:
                XCTAssertFalse(fallbackSchemeChecked)
                fallbackSchemeChecked = true
                checkCanOpenFallbackScheme.fulfill()
                return false
            default:
                XCTFail("Attempting to open unexpected scheme: \(String(describing: url.scheme))")
                return false
            }
        }
        
        let mockConnection = MockServerConnection()
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let urlOpenStarted = expectation(description: "urlOpenStarted")
        let urlDecisionFirstLinkResult = expectation(description: "urlDecisionFirstLinkResult")
        let urlDecisionNextLinkResult = expectation(description: "urlDecisionNextLinkResult")
        
        mockWebView = MockWebView(
            onLoad: [
                { [weak self] request in
                    guard let self = self else {
                        XCTFail("self not found")
                        return nil
                    }
                    XCTAssertEqual(request.url, URL(string: self.someHttpLink))
                    urlOpenStarted.fulfill()
                    self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: request)) { [weak self] policy in
                        guard let self = self else {
                            XCTFail("self not found")
                            return
                        }
                        XCTAssertEqual(policy, .allow)
                        urlDecisionFirstLinkResult.fulfill()
                        
                        // The emulated redirect happens here
                        let redirectRequest = URLRequest(url: otherLink)
                        
                        self.navigationHandler.webView(self.mockWebView, decidePolicyFor: MockWKNavigationAction(mockedRequest: redirectRequest)) { [weak self] policy in
                            guard let self = self else {
                                XCTFail("self not found")
                                return
                            }
                            XCTAssertEqual(policy, .cancel)
                            urlDecisionNextLinkResult.fulfill()
                            self.navigationHandler.webView(self.mockWebView, didFailProvisionalNavigation: nil, withError: SomeError.whatever)
                        }
                    }
                    return nil
                }
            ]
        )
        
        navigationHandler = PBMClickthroughBrowserNavigationHandler(webView: mockWebView)
        
        let urlOpenFinished = expectation(description: "urlOpenFinished")
        
        navigationHandler.open(link) { shouldBeShown in
            XCTAssertFalse(shouldBeShown)
            urlOpenFinished.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Private extension helper classes

extension PBMClickthroughBrowserNavigationHandlerTest {
    private class MockWebView: NSObject, PBMWKWebViewCompatible {
        typealias LoadHandler = (URLRequest) -> WKNavigation?
        
        private(set) var onLoad: [LoadHandler]
        
        init(onLoad: [LoadHandler] = []) {
            self.onLoad = onLoad
        }
        
        func load(_ request: URLRequest) -> WKNavigation? {
            guard onLoad.count > 0 else {
                XCTFail("no handler for \(#function): \(request)")
                return nil
            }
            let handler = onLoad.remove(at: 0)
            return handler(request)
        }
        
        func addLoadHandlers(_ loadHandlers: [LoadHandler]) {
            onLoad += loadHandlers
        }
        
        func removeLoadHandlers() {
            onLoad = []
        }
        
        func setLoadHandlers(loadHandlers: [LoadHandler]) {
            removeLoadHandlers()
            addLoadHandlers(loadHandlers)
        }
    }
}

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

class PBMDeepLinkPlusHelperTest: XCTestCase {
    func testDeepLinkDetection() {
        let isDeepLinkPlus: (String)->Bool = { urlString in
            let url: URL! = URL(string: urlString)
            XCTAssertNotNil(url)
            return PBMDeepLinkPlusHelper.isDeepLinkPlusURL(url)
        }
        XCTAssertTrue(isDeepLinkPlus("deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=http%3A%2F%2Fmobile.twitter.com"))
        XCTAssertTrue(isDeepLinkPlus("deeplink+://navigate?primaryUrl=app-settings%3A"))
        
        XCTAssertTrue(isDeepLinkPlus("deeplink+://navigate?primaryUrl=cr%40%20%3Cb%5Bb%3E%20y%5D%20%24%2344"))
        
        XCTAssertFalse(isDeepLinkPlus("http://foo.bar"))
        XCTAssertFalse(isDeepLinkPlus("https://google.com/"))
        XCTAssertFalse(isDeepLinkPlus("twitter://timeline"))
    }
    
    func testDemoLinkHandlingPrimary() {
        let demoLinkString = "deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=http%3A%2F%2Fmobile.twitter.com"
        
        guard let demoURL = URL(string: demoLinkString) else {
            XCTFail("Failed to parse demo URL")
            return
        }
        
        let attemptedToOpenTwitter = expectation(description: "attemptedToOpenTwitter")
        
        let mockApplication = MockUIApplication()
        mockApplication.openURLClosure = { url in
            XCTAssertEqual(url, URL(string: "twitter://timeline"))
            attemptedToOpenTwitter.fulfill()
            return true
        }
        
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let mockConnection = MockServerConnection(
            onGet: [
                { (url, timeout, callback) in
                    XCTAssertEqual(url, "http://mopub.com/clicktracking")
                },
                { (url, timeout, callback) in
                    XCTAssertEqual(url, "http://mopub.com/mopubtracking")
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let deepLinkResolved = expectation(description: "deepLinkResolved")
        
        PBMDeepLinkPlusHelper.tryHandleDeepLinkPlus(demoURL) { (visited, fallbackURL, fallbackTrackingURLs) in
            XCTAssertTrue(visited)
            XCTAssertNil(fallbackURL)
            XCTAssertNil(fallbackTrackingURLs)
            deepLinkResolved.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testDemoLinkHandlingFallback() {
        let demoLinkString = "deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=http%3A%2F%2Fmobile.twitter.com&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fclicktracking&fallbackTrackingUrl=http%3A%2F%2Fmopub.net%2Fmopubtracking"
        
        guard let demoURL = URL(string: demoLinkString) else {
            XCTFail("Failed to parse demo URL")
            return
        }
        
        let attemptedToOpenTwitter = expectation(description: "attemptedToOpenTwitter")
        
        let mockApplication = MockUIApplication()
        mockApplication.openURLClosure = { url in
            XCTAssertEqual(url, URL(string: "twitter://timeline"))
            attemptedToOpenTwitter.fulfill()
            return false
        }
        
        let mockConnection = MockServerConnection()
        
        PBMDeepLinkPlusHelper.application = mockApplication
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        let deepLinkResolved = expectation(description: "deepLinkResolved")
        
        PBMDeepLinkPlusHelper.tryHandleDeepLinkPlus(demoURL) { (visited, fallbackURL, fallbackTrackingURLs) in
            XCTAssertFalse(visited)
            XCTAssertEqual(fallbackURL, URL(string: "http://mobile.twitter.com"))
            XCTAssertNotNil(fallbackTrackingURLs)
            XCTAssertEqual(fallbackTrackingURLs?.count, 2)
            XCTAssertEqual(fallbackTrackingURLs?[0], URL(string: "http://mopub.net/clicktracking"))
            XCTAssertEqual(fallbackTrackingURLs?[1], URL(string: "http://mopub.net/mopubtracking"))
            deepLinkResolved.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testVisitingTrackingLinks() {
        let trackingLinksVisited = expectation(description: "trackingLinksVisited")
        
        let linkStrings = ["http://mopub.com/clicktracking", "http://mopub.com/mopubtracking"]
        let links = linkStrings.compactMap(URL.init(string:))
        
        let mockConnection = MockServerConnection(
            onGet: [
                { (url, timeout, callback) in
                    XCTAssertEqual(url, linkStrings[0])
                },
                { (url, timeout, callback) in
                    XCTAssertEqual(url, linkStrings[1])
                    trackingLinksVisited.fulfill()
                }
            ]
        )
        
        PBMDeepLinkPlusHelper.connection = mockConnection
        
        PBMDeepLinkPlusHelper.visitTrackingURLs(links)
        
        waitForExpectations(timeout: 1)
    }
}

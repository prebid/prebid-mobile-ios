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

class PBMDeepLinkPlusTest: XCTestCase {
    func testDemoLinkParsing() {
        let demoURLString = "deeplink+://navigate?primaryUrl=twitter%3A%2F%2Ftimeline&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fclicktracking&primaryTrackingUrl=http%3A%2F%2Fmopub.com%2Fmopubtracking&fallbackUrl=http%3A%2F%2Fmobile.twitter.com";
        
        guard let demoURL = URL(string: demoURLString), let deepLink = PBMDeepLinkPlus(url: demoURL) else {
            XCTFail("Failed to parse demo URL")
            return
        }
        
        XCTAssertEqual(deepLink.primaryURL, URL(string: "twitter://timeline"))
        XCTAssertEqual(deepLink.primaryTrackingURLs?.count, 2)
        XCTAssertEqual(deepLink.primaryTrackingURLs?[0], URL(string: "http://mopub.com/clicktracking"))
        XCTAssertEqual(deepLink.primaryTrackingURLs?[1], URL(string: "http://mopub.com/mopubtracking"))
        XCTAssertEqual(deepLink.fallbackURL, URL(string: "http://mobile.twitter.com"))
        XCTAssertNil(deepLink.fallbackTrackingURLs)
    }
    
    func testAppSettingsLinkParsing() {
        let settingsURLString = "deeplink+://navigate?primaryUrl=app-settings%3A"
        
        guard let settingsURL = URL(string: settingsURLString), let deepLink = PBMDeepLinkPlus(url: settingsURL) else {
            XCTFail("Failed to parse settings deep link")
            return
        }
        
        XCTAssertEqual(deepLink.primaryURL, URL(string: "app-settings:"))
        XCTAssertNil(deepLink.primaryTrackingURLs)
        XCTAssertNil(deepLink.fallbackURL)
        XCTAssertNil(deepLink.fallbackTrackingURLs)
    }
    
    func testBrokenPrimaryLinkParsing() {
        let brokenURLString = "deeplink+://navigate?primaryUrl=cr%40%20%3Cb%5Bb%3E%20y%5D%20%24%2344"
        
        let url: URL! = URL(string: brokenURLString)
        
        let deepLink = PBMDeepLinkPlus(url: url)
        XCTAssertNil(deepLink)
    }
}

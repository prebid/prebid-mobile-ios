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

class URLComponentsTests:XCTestCase {

    func testInit() {
        
        var baseURL:String
        var urlComponents:URLComponents
        var fullURL:String
        
        //Basic
        urlComponents = URLComponents(string: "openx.com")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "bin")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=bar") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("baz=bin") == 1, "fullURL = \(fullURL)")
        
        //Empty baseURL
        urlComponents = URLComponents(string: "")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "bin")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=bar") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("baz=bin") == 1, "fullURL = \(fullURL)")
        
        //Empty query args and url
        urlComponents = URLComponents(string: "openx.com")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 0, "fullURL = \(fullURL)")
        
        //Empty but has trailing ? in base URL string
        urlComponents = URLComponents(string: "openx.com?")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 0, "fullURL = \(fullURL)")
        
        //Empty query args array but Base URL has 1 key-value pair
        urlComponents = URLComponents(string: "openx.com?foo=bar")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 1, "fullURL = \(fullURL)")
        
        //Key-val pair overrwite from base
        urlComponents = URLComponents(string: "openx.com?foo=bar")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "baz")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        
        //One overrwite from base, one append
        baseURL = "openx.com?foo=bar"
        urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "baz"), URLQueryItem(name: "bing", value: "boom")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=bar") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("bing=boom") == 1, "fullURL = \(fullURL)")
    }

    func testURLPercentEncoding() {
        var baseURL:String
        var urlComponents:URLComponents
        var fullURL:String
        var argumentString:String

        baseURL = "openx.com"

        // This query item array intentionally has a query parameter/value pair embeded in another query value.
        urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "baz"), URLQueryItem(name: "bing", value: "boom&hidden=param")]
        fullURL = urlComponents.string!
        argumentString = urlComponents.query!

        XCTAssert(fullURL.PBMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("bing=boom%26hidden%3Dparam") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.PBMnumberOfMatches("hidden=param") == 0, "fullURL = \(fullURL)")

        XCTAssert(argumentString.PBMnumberOfMatches("\\?") == 0, "argumentString = \(argumentString)")
        XCTAssert(argumentString.PBMnumberOfMatches("\\&") == 2, "argumentString = \(argumentString)")
        XCTAssert(argumentString.PBMnumberOfMatches("foo=baz") == 1, "fullURL = \(argumentString)")
        XCTAssert(argumentString.PBMnumberOfMatches("bing=boom\\&hidden=param") == 1, "fullURL = \(argumentString)")
        XCTAssert(argumentString.PBMnumberOfMatches("hidden=param") == 1, "fullURL = \(argumentString)")
    }
}

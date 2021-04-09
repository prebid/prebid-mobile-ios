import XCTest
@testable import OpenXApolloSDK

class URLComponentsTests:XCTestCase {

    func testInit() {
        
        var baseURL:String
        var urlComponents:URLComponents
        var fullURL:String
        
        //Basic
        urlComponents = URLComponents(string: "openx.com")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "bin")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=bar") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("baz=bin") == 1, "fullURL = \(fullURL)")
        
        //Empty baseURL
        urlComponents = URLComponents(string: "")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "bin")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=bar") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("baz=bin") == 1, "fullURL = \(fullURL)")
        
        //Empty query args and url
        urlComponents = URLComponents(string: "openx.com")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 0, "fullURL = \(fullURL)")
        
        //Empty but has trailing ? in base URL string
        urlComponents = URLComponents(string: "openx.com?")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 0, "fullURL = \(fullURL)")
        
        //Empty query args array but Base URL has 1 key-value pair
        urlComponents = URLComponents(string: "openx.com?foo=bar")!
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 1, "fullURL = \(fullURL)")
        
        //Key-val pair overrwite from base
        urlComponents = URLComponents(string: "openx.com?foo=bar")!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "baz")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        
        //One overrwite from base, one append
        baseURL = "openx.com?foo=bar"
        urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [URLQueryItem(name: "foo", value: "baz"), URLQueryItem(name: "bing", value: "boom")]
        fullURL = urlComponents.string!
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("=") == 2, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=bar") == 0, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("bing=boom") == 1, "fullURL = \(fullURL)")
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

        XCTAssert(fullURL.OXMnumberOfMatches("\\?") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("\\&") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("foo=baz") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("bing=boom%26hidden%3Dparam") == 1, "fullURL = \(fullURL)")
        XCTAssert(fullURL.OXMnumberOfMatches("hidden=param") == 0, "fullURL = \(fullURL)")

        XCTAssert(argumentString.OXMnumberOfMatches("\\?") == 0, "argumentString = \(argumentString)")
        XCTAssert(argumentString.OXMnumberOfMatches("\\&") == 2, "argumentString = \(argumentString)")
        XCTAssert(argumentString.OXMnumberOfMatches("foo=baz") == 1, "fullURL = \(argumentString)")
        XCTAssert(argumentString.OXMnumberOfMatches("bing=boom\\&hidden=param") == 1, "fullURL = \(argumentString)")
        XCTAssert(argumentString.OXMnumberOfMatches("hidden=param") == 1, "fullURL = \(argumentString)")
    }
}

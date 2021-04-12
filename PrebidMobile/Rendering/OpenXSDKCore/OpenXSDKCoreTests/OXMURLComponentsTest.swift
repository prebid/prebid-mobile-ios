//
//  OXMURLComponentsTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class OXMURLComponentsTest: XCTestCase {
    
    //Demonstrate OXMURLComponents will overwrite and append key-val pairs, then sort them.
    func testPositive() {
        let traceParamDict = ["overwritekey" : "overwriteval", "appendkey" : "appendval"]
        let strURL = "https://foo.com/?overwritekey=bar"
        
        let urlComponents = OXMURLComponents.init(url:strURL, paramsDict:traceParamDict)!
        
        let expected = "https://foo.com/?appendkey=appendval&overwritekey=overwriteval"
        let actual = urlComponents.fullURL
        XCTAssert(expected == actual as String, "expected \(expected), got \(actual)")   
    }
    
    //URLComponents and NSURLComponents treat square brackets as a malformed URL.
    //Since OXMURLComponents depends on them, it will fail as well.
    func testNegativeFailOnSquareBrackets() {
        let traceParamDict = ["key1" : "val1", "key2" : "val2"]
        let strURL = "https://foo.com?ad_mt=[AD_MT]"
        
        let urlComponents = OXMURLComponents.init(url:strURL, paramsDict:traceParamDict)
        XCTAssert(urlComponents == nil)
    }
}

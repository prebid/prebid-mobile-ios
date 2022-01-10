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
@testable import PrebidMobileAdMobAdapters

class AdMobUtilsTest: XCTestCase {

    func testServerParameterChecking() {
        let serverParameter = "{\"hb_pb\":\"0.10\"}"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        
        XCTAssertTrue(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testMultipleServerParameterChecking() {
        let serverParameter = "{\"hb_pb\":\"0.10\", \"hb_size\":\"320x50\"}"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
       XCTAssertTrue(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testMultipleWrongServerParameter() {
        let serverParameter = "{\"hb_pb\":\"0.50\", \"hb_size\":\"300x250\"}"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testEmptyJSONServerParameter() {
        let serverParameter = "{}"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testEmptyServerParameter() {
        let serverParameter = ""
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testWrongServerParameterFormat() {
        let serverParameter = "hb_size:320x50"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testWrongServerParameter() {
        let serverParameter = "{\"par\":\"123\"}"
        let keywords = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testWrongUserKeywordsFormat() {
        let serverParameter = "{\"par\":\"123\"}"
        let keywords = ["hb_size;320x50"]
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }
    
    func testEmptyUserKeywords() {
        let serverParameter = "{\"par\":\"123\"}"
        let keywords = [String]()
        
        XCTAssertFalse(AdMobUtils.isServerParameterInKeywords(serverParameter, keywords))
    }

    func testRemoveHBKeywords() {
        let keywords = ["hb_pb:0.10", "hb_size:320x50", "par:123"]
        
        XCTAssertEqual(AdMobUtils.removeHBKeywordsFrom(keywords), ["par:123"])
    }
}

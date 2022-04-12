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
import UIKit
@testable import PrebidMobile

class MediationUtilsTest: XCTestCase {
    func testServerParameterChecking() {
        let serverParameter = ["hb_pb":"0.10"]
        let targetingInfo = ["hb_size":"320x50", "hb_pb":"0.10", "hb_size_openx":"320x50"]
        
        XCTAssertTrue(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testMultipleServerParameterChecking() {
        let serverParameter = ["hb_pb":"0.10", "hb_size":"320x50"]
        let targetingInfo = ["hb_size":"320x50", "hb_pb":"0.10", "hb_size_openx":"320x50"]
        
       XCTAssertTrue(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testMultipleWrongServerParameter() {
        let serverParameter = ["hb_pb":"0.50", "hb_size":"300x250"]
        let targetingInfo = ["hb_size":"320x50", "hb_pb":"0.10", "hb_size_openx":"320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testEmptyJSONServerParameter() {
        let serverParameter = [String: String]()
        let targetingInfo = ["hb_size":"320x50", "hb_pb":"0.10", "hb_size_openx":"320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testWrongServerParameter() {
        let serverParameter = ["par":"123"]
        let targetingInfo = ["hb_size":"320x50", "hb_pb":"0.10", "hb_size_openx":"320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testEmptyTargetingInfo() {
        let serverParameter = ["par":"123"]
        let targetingInfo = [String: String]()
        
        XCTAssertFalse(MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo))
    }
    
    func testStringServerParameterChecking() {
        let serverParameter = "{\"hb_pb\":\"0.10\"}"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        
        XCTAssertTrue(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testMultipleStringServerParameterChecking() {
        let serverParameter = "{\"hb_pb\":\"0.10\", \"hb_size\":\"320x50\"}"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
       XCTAssertTrue(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testMultipleWrongStringServerParameter() {
        let serverParameter = "{\"hb_pb\":\"0.50\", \"hb_size\":\"300x250\"}"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testEmptyStringJSONServerParameter() {
        let serverParameter = "{}"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testEmptyServerParameterInStringTargetinInfo() {
        let serverParameter = ""
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testWrongStringServerParameterFormat() {
        let serverParameter = "hb_size:320x50"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testWrongStringServerParameter() {
        let serverParameter = "{\"par\":\"123\"}"
        let targetingInfo = ["hb_size:320x50", "hb_pb:0.10", "hb_size_openx:320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testWrongStringUserKeywordsFormat() {
        let serverParameter = "{\"par\":\"123\"}"
        let targetingInfo = ["hb_size;320x50"]
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
    
    func testEmptyStringUserKeywords() {
        let serverParameter = "{\"par\":\"123\"}"
        let targetingInfo = [String]()
        
        XCTAssertFalse(MediationUtils.isServerParameterInTargetingInfo(serverParameter, targetingInfo))
    }
}

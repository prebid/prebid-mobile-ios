/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

class ArbitraryORTBHelperTests: XCTestCase {
    
    func testImpORTBHelper_ValidJSON() {
        let validJSON = """
        {
           "key1": "value1",
           "key2": 123
        }
        """
        
        let result = ArbitraryImpORTBHelper(ortb: validJSON).getValidatedORTBDict()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["key1"] as? String, "value1")
        XCTAssertEqual(result?["key2"] as? Int, 123)
    }
    
    func testImpORTBHelper_InvalidJSON() {
        let invalidJSON = """
        {
            "key1": "value1",
            "key2":
        """
        
        let result = ArbitraryImpORTBHelper(ortb: invalidJSON).getValidatedORTBDict()
        
        XCTAssertNil(result)
    }
    
    func testGlobalORTBHelper_ValidJSON_RemoveProtectedFields() {
        let json = """
          {
              "regs": {
                  "ext": {
                      "gdpr": 1,
                      "us_privacy": "1NY"
                  },
                  "gpp_sid": [1, 2],
                  "gpp": "some_value"
              },
              "device": {
                  "ext": {
                      "atts": 2,
                      "ifv": "some_id"
                  },
                  "geo": {
                      "lat": 37,
                      "lon": -122
                  },
                  "w": 320,
                  "h": 480,
                  "lmt": 1,
                  "make": "Apple",
                  "model": "iPhone",
                  "os": "iOS",
                  "osv": "17.5",
                  "pxratio": 3,
                  "ua": "placeholder-user-agent",
                  "hwv": "hardware-version-placeholder",
                  "ifa": "placeholder-ifa",
                  "language": "placeholder-language",
                  "connectiontype": 2
              },
              "user": {
                  "ext": {
                      "consent": "some_consent"
                  },
                  "geo": {
                      "lat": 12.34,
                      "lon": 56.78
                  }
              }
          }
        """
        
        let result = ArbitraryGlobalORTBHelper(ortb: json).getValidatedORTBDict()
        
        XCTAssertNotNil(result)
        
        let regs = result?["regs"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.regsProps {
            XCTAssertNil(regs[prop])
        }
        
        let regsExt = regs["ext"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.regsExtProps {
            XCTAssertNil(regsExt[prop])
        }
        
        let device = result?["device"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.deviceProps {
            XCTAssertNil(device[prop])
        }
        
        let deviceExt = device["ext"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.deviceExtProps {
            XCTAssertNil(deviceExt[prop])
        }
        
        let user = result?["user"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.userProps {
            XCTAssertNil(user[prop])
        }
        
        let userExt = user["ext"] as! [String: Any]
        for prop in ArbitraryGlobalORTBHelper.ProtectedFields.userExtProps {
            XCTAssertNil(userExt[prop])
        }
    }
    
    func testGlobalORTBHelper_InvalidJSON() {
        let invalidJSON = """
        {
           "key1": "value1",
           "key2":
        """
        
        let result = ArbitraryGlobalORTBHelper(ortb: invalidJSON).getValidatedORTBDict()
        
        XCTAssertNil(result)
    }
}

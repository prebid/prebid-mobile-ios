/*   Copyright 2018-2025 Prebid.org, Inc.
 
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

class UserUniqueIDTests: XCTestCase {
    
    func testInitialization() {
        let userUniqueID = UserUniqueID(id: "uid1", aType: 1, ext: ["key": "value"])
        
        XCTAssertEqual(userUniqueID.id, "uid1")
        XCTAssertEqual(userUniqueID.aType, 1)
        XCTAssertEqual(userUniqueID.ext as? NSDictionary, ["key": "value"] as NSDictionary)
    }
    
    func testToJSONDictionary() {
        let userUniqueID = UserUniqueID(id: "uid1", aType: 1, ext: ["key": "value"])
        let json = userUniqueID.toJSONDictionary()
        
        XCTAssertEqual(json["id"] as? String, "uid1")
        XCTAssertEqual(json["atype"] as? NSNumber, 1)
        XCTAssertEqual((json["ext"] as? [String: Any])?["key"] as? String, "value")
    }
}

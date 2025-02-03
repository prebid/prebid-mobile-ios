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

class ExternalUserIdTests: XCTestCase {
    
    func testInitialization() {
        let uids = [UserUniqueID(id: "uid1", aType: 1)]
        let ext: [String: Any] = ["key": "value"]
        let externalUserId = ExternalUserId(source: "source1", uids: uids, ext: ext)
        
        XCTAssertEqual(externalUserId.source, "source1")
        XCTAssertEqual(externalUserId.uids.count, 1)
        XCTAssertEqual(externalUserId.uids, uids)
        XCTAssertEqual(externalUserId.ext as? NSDictionary, ext as NSDictionary)
    }
    
    func testToJSONDictionary() {
        let uids = [UserUniqueID(id: "uid1", aType: 1)]
        let ext: [String: Any] = ["key": "value"]
        let externalUserId = ExternalUserId(source: "source1", uids: uids, ext: ext)
        
        let json = externalUserId.toJSONDictionary()
        
        XCTAssertEqual(json["source"] as? String, "source1")
        XCTAssertNotNil(json["uids"])
        XCTAssertEqual(json["uids"] as? [NSDictionary], [["id": "uid1", "atype": 1]] as [NSDictionary])
        XCTAssertEqual((json["ext"] as? [String: Any])?["key"] as? String, "value")
    }
    
    func testDeprecatedInitializer() {
        let uids = [UserUniqueID(id: "uid1", aType: 1)]
        let ext: [String: Any] = ["key": "value"]
        let externalUserId = ExternalUserId(source: "source1", identifier: "id123", atype: 2, ext: ext)
        
        XCTAssertEqual(externalUserId.source, "source1")
        XCTAssertEqual(externalUserId.identifier, "id123")
        XCTAssertEqual(externalUserId.atype, 2)
        XCTAssertEqual(externalUserId.ext as? NSDictionary, ext as NSDictionary)
    }
}

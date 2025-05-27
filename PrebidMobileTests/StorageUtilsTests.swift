/*   Copyright 2018-2025 Prebid.org, Inc.

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

class StorageUtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: StorageUtils.PB_SharedIdKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: StorageUtils.PB_SharedIdKey)
        super.tearDown()
    }

    func testSharedId_SetAndGet() {
        let testValue = "TestSharedID"
        
        StorageUtils.sharedId = testValue
        let retrievedValue = StorageUtils.sharedId
        
        XCTAssertEqual(retrievedValue, testValue)
    }
    
    func testSharedId_Remove() {
        StorageUtils.sharedId = "TemporaryID"
        StorageUtils.sharedId = nil
        
        let retrievedValue = UserDefaults.standard.string(forKey: StorageUtils.PB_SharedIdKey)
        XCTAssertNil(retrievedValue)
    }
    
    func testSharedId_DefaultValue() {
        let retrievedValue = StorageUtils.sharedId
        XCTAssertNil(retrievedValue)
    }
}

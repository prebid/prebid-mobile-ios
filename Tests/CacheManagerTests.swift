/*   Copyright 2019-2020 Prebid.org, Inc.

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

class CacheManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCacheManagerSaveAndGetAPIsWithMultipleRequests() {
        let content1 = "Prebid Native Ad"
        let cacheId1 = CacheManager.shared.save(content: content1)

        let content2 = "Prebid Native Ad 2"
        let cacheId2 = CacheManager.shared.save(content: content2)
        
        let content3 = "Prebid Native Ad 3"
        let cacheId3 = CacheManager.shared.save(content: content3)
        
        XCTAssertTrue(cacheId1!.contains("Prebid_"))
        XCTAssertTrue(CacheManager.shared.isValid(cacheId: cacheId2!))
        XCTAssertEqual(content2, CacheManager.shared.get(cacheId: cacheId2!))
        XCTAssertFalse(CacheManager.shared.isValid(cacheId: cacheId2!))
        XCTAssertEqual(nil, CacheManager.shared.get(cacheId: cacheId2!))
        
        XCTAssertTrue(cacheId2!.contains("Prebid_"))
        XCTAssertTrue(CacheManager.shared.isValid(cacheId: cacheId1!))
        XCTAssertEqual(content1, CacheManager.shared.get(cacheId: cacheId1!))
        XCTAssertFalse(CacheManager.shared.isValid(cacheId: cacheId1!))
        XCTAssertEqual(nil, CacheManager.shared.get(cacheId: cacheId1!))
        
        XCTAssertTrue(cacheId3!.contains("Prebid_"))
        XCTAssertTrue(CacheManager.shared.isValid(cacheId: cacheId3!))
        XCTAssertEqual(content3, CacheManager.shared.get(cacheId: cacheId3!))
        XCTAssertFalse(CacheManager.shared.isValid(cacheId: cacheId3!))
        XCTAssertEqual(nil, CacheManager.shared.get(cacheId: cacheId3!))
        
        
    }


}

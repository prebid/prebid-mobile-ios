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
        super.setUp()
        
        CacheManager.shared.savedValuesDict = [:]
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
        
        XCTAssertTrue(cacheId2!.contains("Prebid_"))
        XCTAssertTrue(CacheManager.shared.isValid(cacheId: cacheId1!))
        XCTAssertEqual(content1, CacheManager.shared.get(cacheId: cacheId1!))

        
        XCTAssertTrue(cacheId3!.contains("Prebid_"))
        XCTAssertTrue(CacheManager.shared.isValid(cacheId: cacheId3!))
        XCTAssertEqual(content3, CacheManager.shared.get(cacheId: cacheId3!))
    }

    func testCacheManagerMultipleNativeAdDelegates() {
        let nativeContent = "{\"adm\":\"{\\\"assets\\\":[{\\\"required\\\":1,\\\"title\\\":{\\\"text\\\":\\\"Prebid (Title)\\\"}},{\\\"id\\\":2,\\\"required\\\":1,\\\"img\\\":{\\\"type\\\":3,\\\"url\\\":\\\"https:\\/\\/s3.amazonaws.com\\/files.prebid.org\\/creatives\\/prebid728x90.png\\\"}},{\\\"id\\\":3,\\\"required\\\":1,\\\"data\\\":{\\\"type\\\":1,\\\"value\\\":\\\"Prebid (Brand)\\\"}}],\\\"link\\\":{\\\"url\\\":\\\"https:\\/\\/prebid.org\\/\\\"}}\",\"ext\":{\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"0064e6b4-e051-4b6c-ab96-0b32af9dd7d0\",\"url\":\"https:\\/\\/prebid-server-test-j.prebid.org\\/cache?uuid=0064e6b4-e051-4b6c-ab96-0b32af9dd7d0\"}},\"targeting\":{\"hb_bidder\":\"prebid\",\"hb_bidder_prebid\":\"prebid\",\"hb_cache_host\":\"prebid-server-test-j.prebid.org\",\"hb_cache_host_prebid\":\"prebid-server-test-j.prebid.org\",\"hb_cache_id\":\"0064e6b4-e051-4b6c-ab96-0b32af9dd7d0\",\"hb_cache_id_prebid\":\"0064e6b4-e051-4b6c-ab96-0b32af9dd7d0\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_prebid\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_prebid\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_prebid\":\"0.10\"},\"type\":\"native\"}},\"id\":\"prebid-ita-response-banner-native-styles\",\"impid\":\"58C2A794-C3F0-4D3D-B19D-4D1E1908CB09\",\"price\":0.10000000000000001}"
        
        let cacheId1 = CacheManager.shared.save(content: nativeContent, expireInterval: 3)
        _ = NativeAd.create(cacheId: cacheId1!)
        
        let cacheId2 = CacheManager.shared.save(content: nativeContent, expireInterval: 3)
        _ = NativeAd.create(cacheId: cacheId2!)
        
        let cacheId3 = CacheManager.shared.save(content: nativeContent, expireInterval: 3)
        _ = NativeAd.create(cacheId: cacheId3!)
        
        XCTAssertTrue(CacheManager.shared.savedValuesDict.count == 3)
        XCTAssertTrue(CacheManager.shared.delegates.count == 3)
        
        let expireExpectation = expectation(description: "Cache manager removed expired content and delegates")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            XCTAssertTrue(CacheManager.shared.savedValuesDict.isEmpty)
            XCTAssertTrue(CacheManager.shared.delegates.isEmpty)
            
            expireExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }

    func testConcurrency() {
        let manager = CacheManager.shared
        for _ in 1 ... 1000 {
            let expectation = XCTestExpectation(description: "All tasks are done")
            expectation.expectedFulfillmentCount = 2
            let concurrentQueue = DispatchQueue(label: "test", attributes: .concurrent)
            concurrentQueue.async {
                _ = manager.save(content: UUID().uuidString)
                expectation.fulfill()
            }
            concurrentQueue.async {
                _ = manager.get(cacheId: "1")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
}

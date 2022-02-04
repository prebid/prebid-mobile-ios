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
import MoPubSDK
import PrebidMobile
@testable import PrebidMobileMoPubAdapters

class PBMMoPubNativeUtilsTest: XCTestCase, RawWinningBidFabricator {
    func testFindNativeAd() {
        let emptyExtras: [AnyHashable : Any] = [:]
        let errorExpectation = expectation(description: "Error finding native ad expectation")
        
        MoPubMediationNativeUtils.findNative(emptyExtras) { result in
            switch result {
            case .failure(_):
                errorExpectation.fulfill()
            case .success(_):
                break
            }
        }
        waitForExpectations(timeout: 0.1)
        
        let markupString = """
                   {\"impid\":\"2CA244FB-489F-486C-A314-D62079D49129\",\"adm\":\"{ \\\"assets\\\": [{ \\\"required\\\": 1, \\\"title\\\": { \\\"text\\\": \\\"OpenX (Title)\\\" } }, { \\\"required\\\": 1, \\\"img\\\": { \\\"type\\\": 1, \\\"url\\\": \\\"https:\\/\\/www.saashub.com\\/images\\/app\\/service_logos\\/5\\/1df363c9a850\\/large.png?1525414023\\\" } }, { \\\"required\\\": 1, \\\"img\\\": { \\\"type\\\": 3, \\\"url\\\": \\\"https:\\/\\/ssl-i.cdn.openx.com\\/mobile\\/demo-creatives\\/mobile-demo-banner-640x100.png\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 1, \\\"value\\\": \\\"OpenX (Brand)\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 2, \\\"value\\\": \\\"Learn all about this awesome story of someone using out OpenX SDK.\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 12, \\\"value\\\": \\\"Click here to visit our site!\\\" } } ], \\\"link\\\":{ \\\"url\\\": \\\"https:\\/\\/www.openx.com\\/\\\", \\\"clicktrackers\\\":[\\\"https:\\/\\/10.0.2.2:8000\\/events\\/click\\/root\\/url\\\"] }, \\\"eventtrackers\\\":[ { \\\"event\\\":1, \\\"method\\\":1, \\\"url\\\":\\\"https:\\/\\/10.0.2.2:8000\\/events\\/tracker\\/impression\\\" }, { \\\"event\\\":2, \\\"method\\\":1, \\\"url\\\":\\\"https:\\/\\/10.0.2.2:8000\\/events\\/tracker\\/mrc50\\\" }, { \\\"event\\\":3, \\\"method\\\":1, \\\"url\\\":\\\"https:\\/\\/10.0.2.2:8000\\/events\\/tracker\\/mrc100\\\" },{\\\"event\\\":555,\\\"method\\\":2,\\\"url\\\":\\\"http:\\/\\/10.0.2.2:8002\\/static\\/omid-validation-verification-script-v1-ios-video.js\\\",\\\"ext\\\":{\\\"vendorKey\\\":\\\"iabtechlab.com-omid\\\",\\\"verification_parameters\\\":\\\"iabtechlab-openx\\\"}} ] }\",\"w\":300,\"adid\":\"test-ad-id-12345\",\"h\":250,\"crid\":\"test-creative-id-1\",\"price\":0.10000000000000001,\"adomain\":[\"openx.com\"],\"id\":\"test-bid-id-1\",\"ext\":{\"prebid\":{\"video\":{\"primary_category\":\"\",\"duration\":0},\"targeting\":{\"hb_pb_openx\":\"0.10\",\"hb_cache_host_openx\":\"10.0.2.2:8000\",\"hb_size_openx\":\"300x250\",\"hb_cache_id_openx\":\"native-default-example\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_cache_path\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_cache_host\":\"10.0.2.2:8000\",\"hb_cache_id\":\"native-default-example\",\"hb_bidder_openx\":\"openx\",\"hb_size\":\"300x250\",\"hb_bidder\":\"openx\",\"hb_env_openx\":\"mobile-app\"},\"type\":\"native\",\"cache\":{\"key\":\"\",\"url\":\"\",\"bids\":{\"url\":\"10.0.2.2:8000\\/cache?uuid=native-default-example\",\"cacheId\":\"native-default-example\"}}},\"bidder\":{\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"matching_ad_id\":{\"placement_id\":2,\"campaign_id\":1,\"creative_id\":3},\"ad_ox_cats\":[2],\"buyer_id\":\"buyer_10\",\"next_highest_bid_price\":0.099000000000000005}}}
"""
        guard let cacheId = CacheManager.shared.save(content: markupString) else {
            XCTFail("No cacheId")
            return
        }
        
        let extras: [AnyHashable : Any] = [PBMMediationAdNativeResponseKey: [PrebidLocalCacheIdKey: cacheId]]
        let successExpectation = expectation(description: "Success finding Native Ad expectation")
        MoPubMediationNativeUtils.findNative(extras) { result in
            switch result {
            case .failure(_):
                break
            case .success(_):
                successExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}

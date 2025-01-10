/*   Copyright 2018-2019 Prebid.org, Inc.

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

class NativeAdTests: XCTestCase {
    
    var nativeAdString: String {
        "{\"adm\":\"{\\\"assets\\\":[{\\\"required\\\":1,\\\"title\\\":{\\\"text\\\":\\\"title\\\"}},{\\\"id\\\":1,\\\"required\\\":1,\\\"img\\\":{\\\"type\\\":1,\\\"url\\\":\\\"https:\\/\\/www.testUrl.com\\/images\\/app\\/service_logos\\/5\\/1df363c9a850\\/large.png?1525414023\\\"}},{\\\"id\\\":2,\\\"required\\\":1,\\\"img\\\":{\\\"type\\\":3,\\\"url\\\":\\\"https:\\/\\/testUrl.com\\/demo-creatives\\/mobile-demo-banner-640x100.png\\\"}},{\\\"id\\\":3,\\\"required\\\":1,\\\"data\\\":{\\\"type\\\":1,\\\"value\\\":\\\"brand\\\"}},{\\\"id\\\":4,\\\"required\\\":1,\\\"data\\\":{\\\"type\\\":2,\\\"value\\\":\\\"Learn all about this awesome story of someone using out SDK.\\\"}},{\\\"id\\\":5,\\\"required\\\":1,\\\"data\\\":{\\\"type\\\":12,\\\"value\\\":\\\"Click here to visit our site!\\\"}}],\\\"link\\\":{\\\"url\\\":\\\"https:\\/\\/www.testUrl.com\\/\\\",\\\"clicktrackers\\\":[\\\"https:\\/\\/testUrl.com\\/events\\/click\\/root\\/url\\\"]},\\\"eventtrackers\\\":[{\\\"event\\\":1,\\\"method\\\":1,\\\"url\\\":\\\"https:\\/\\/testUrl.com\\/events\\/tracker\\/impression\\\"},{\\\"event\\\":2,\\\"method\\\":1,\\\"url\\\":\\\"https:\\/\\/prebid-server-test-j.prebid.org\\/events\\/tracker\\/mrc50\\\"},{\\\"event\\\":3,\\\"method\\\":1,\\\"url\\\":\\\"https:\\/\\/prebid-server-test-j.prebid.org\\/events\\/tracker\\/mrc100\\\"},{\\\"event\\\":555,\\\"method\\\":2,\\\"url\\\":\\\"https:\\/\\/prebid-mobile-ad-assets.s3.amazonaws.com\\/scripts\\/omid-validation-verification-script-v1.js\\\",\\\"ext\\\":{\\\"vendorKey\\\":\\\"iabtechlab.com-omid\\\",\\\"verification_parameters\\\":\\\"iabtechlab-openx\\\"}}]}\",\"crid\":\"test-creative-id-1\",\"ext\":{\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"18cf38fb-b560-4920-a49c-535f84b9b04a\",\"url\":\"https:\\/\\/prebid-server-test-j.prebid.org\\/cache?uuid=18cf38fb-b560-4920-a49c-535f84b9b04a\"}},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_cache_host\":\"prebid-server-test-j.prebid.org\",\"hb_cache_host_openx\":\"prebid-server-test-j.prebid.org\",\"hb_cache_id\":\"18cf38fb-b560-4920-a49c-535f84b9b04a\",\"hb_cache_id_openx\":\"18cf38fb-b560-4920-a49c-535f84b9b04a\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"native\"}},\"h\":250,\"id\":\"response-prebid-banner-native-styles\",\"impid\":\"38B605F6-BE7E-48CA-921A-BD9B727B37C8\",\"price\":0.10000000000000001,\"w\":300}"
    }
    
    func testNativeAd() {
        let cacheId = CacheManager.shared.save(content: nativeAdString)
        let nativeAd = NativeAd.create(cacheId: cacheId!)
        
        XCTAssertEqual(nativeAd!.titles.first!.text, "title")
        XCTAssertEqual(nativeAd!.images(of: .main).first!.url, "https://testUrl.com/demo-creatives/mobile-demo-banner-640x100.png")
        XCTAssertEqual(nativeAd!.images(of: .icon).first!.url, "https://www.testUrl.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023")
        XCTAssertEqual(nativeAd!.dataObjects(of: .sponsored).first!.value, "brand")
        XCTAssertEqual(nativeAd!.dataObjects(of: .desc).first!.value, "Learn all about this awesome story of someone using out SDK.")
        XCTAssertEqual(nativeAd!.dataObjects(of: .ctaText).first!.value, "Click here to visit our site!")
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.link!.url, "https://www.testUrl.com/")
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.link!.clicktrackers, ["https://testUrl.com/events/click/root/url"])
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.eventtrackers!.first!.url, "https://testUrl.com/events/tracker/impression")
        XCTAssertEqual(nativeAd!.clickURL, "https://www.testUrl.com/")
    }
    
    func testArrayGetters() {
        let cacheId = CacheManager.shared.save(content: nativeAdString)
        let nativeAd = NativeAd.create(cacheId: cacheId!)
        
        XCTAssertEqual(nativeAd?.titles.count, 1)
        XCTAssertEqual(nativeAd?.images.count, 2)
        XCTAssertEqual(nativeAd?.dataObjects.count, 3)
        
        XCTAssertEqual(nativeAd?.images(of: .main).first?.type, 3)
        XCTAssertEqual(nativeAd?.images(of: .icon).first?.type, 1)
        
        XCTAssertEqual(nativeAd?.dataObjects(of: .sponsored).first?.type, 1)
        XCTAssertEqual(nativeAd?.dataObjects(of: .desc).first?.type, 2)
        XCTAssertEqual(nativeAd?.dataObjects(of: .ctaText).first?.type, 12)
    }
}

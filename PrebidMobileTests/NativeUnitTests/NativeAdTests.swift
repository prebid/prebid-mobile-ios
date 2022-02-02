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
    
    func testNativeAd() {
        let stringJson = """
                         {\"id\":\"test-bid-id-1\",\"w\":300,\"adm\":\"{ \\\"assets\\\": [{ \\\"required\\\": 1, \\\"title\\\": { \\\"text\\\": \\\"title\\\" } }, { \\\"required\\\": 1, \\\"img\\\": { \\\"type\\\": 1, \\\"url\\\": \\\"https:\\/\\/www.testUrl.com\\/images\\/app\\/service_logos\\/5\\/1df363c9a850\\/large.png?1525414023\\\" } }, { \\\"required\\\": 1, \\\"img\\\": { \\\"type\\\": 3, \\\"url\\\": \\\"https:\\/\\/testUrl.com\\/mobile\\/demo-creatives\\/mobile-demo-banner-640x100.png\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 1, \\\"value\\\": \\\"brand\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 2, \\\"value\\\": \\\"Learn all about this awesome story of someone using out SDK.\\\" } }, { \\\"required\\\": 1, \\\"data\\\": { \\\"type\\\": 12, \\\"value\\\": \\\"Click here to visit our site!\\\" } } ], \\\"link\\\":{ \\\"url\\\": \\\"https:\\/\\/www.testUrl.com\\/\\\", \\\"clicktrackers\\\":[\\\"https:\\/\\/testUrl.com\\/events\\/click\\/root\\/url\\\"] }, \\\"eventtrackers\\\":[ { \\\"event\\\":1, \\\"method\\\":1, \\\"url\\\":\\\"https:\\/\\/testUrl.com\\/events\\/tracker\\/impression\\\" } ] }\"}
                         """
        let cacheId = CacheManager.shared.save(content: stringJson)
        let nativeAd = NativeAd.create(cacheId: cacheId!)
        
        XCTAssertEqual(nativeAd!.titles.first!.text, "title")
        XCTAssertEqual(nativeAd!.images(of: .main).first!.url, "https://testUrl.com/mobile/demo-creatives/mobile-demo-banner-640x100.png")
        XCTAssertEqual(nativeAd!.images(of: .icon).first!.url, "https://www.testUrl.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023")
        XCTAssertEqual(nativeAd!.dataObjects(of: .sponsored).first!.value, "brand")
        XCTAssertEqual(nativeAd!.dataObjects(of: .desc).first!.value, "Learn all about this awesome story of someone using out SDK.")
        XCTAssertEqual(nativeAd!.dataObjects(of: .ctaText).first!.value, "Click here to visit our site!")
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.link!.url, "https://www.testUrl.com/")
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.link!.clicktrackers, ["https://testUrl.com/events/click/root/url"])
        XCTAssertEqual(nativeAd!.nativeAdMarkup!.eventtrackers!.first!.url, "https://testUrl.com/events/tracker/impression")
    }
}

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
import Foundation
import XCTest

@testable import PrebidMobile

class PBMWinNotifierTest: XCTestCase {
    private let normalTargeting = [
        "hb_cache_host": "prebid.openx.net",
        "hb_cache_path": "/cache",
        "hb_uuid": "d4c70397-e145-4fd6-b57e-70937e42b4ed",
    ]
    private let normalTargetingWithCachedId = [
        "hb_cache_host": "prebid.openx.net",
        "hb_cache_path": "/cache",
        "hb_cache_id": "d4c70397-e145-4fd6-b57e-70937e42b4ed",
    ]
    private let normalTargetingFull = [
        "hb_cache_host": "prebid.openx.net",
        "hb_cache_path": "/cache",
        "hb_uuid": "d4c70397-e145-4fd6-b57e-70937e42b4ed",
        "hb_cache_id": "d4c70397-e145-4fd6-b57e-cacheid",
    ]
    private let cacheIdUrl = "https://prebid.openx.net/cache?uuid=d4c70397-e145-4fd6-b57e-cacheid"
    private let cacheUrl = "https://prebid.openx.net/cache?uuid=d4c70397-e145-4fd6-b57e-70937e42b4ed"
    
    private let someAdm = "ad markup from bid itself"
    private let someNurl = "https://prebid.openx.net/cache?uuid=c2d003d8-3adc-11eb-adc1-0242ac120002"
    private let someNurlMarkup = "ad markup from nurl response"
    private let someCachedMarkup = "ad markup from prebid cache"
    private let someCachedIdMarkup = "ad markup from prebid cache (cache id)"
    private lazy var someCachedIdJSON = """
{
"id":"test-bid-id",
"adm":"\(self.someCachedIdMarkup)"
}
"""
    // MARK: -
    
    func testCacheUrlFromTargeting() {
        XCTAssertEqual(PBMWinNotifier.cacheUrl(fromTargeting: normalTargeting, idKey: "hb_uuid"), cacheUrl)
        XCTAssertEqual(PBMWinNotifier.cacheUrl(fromTargeting: normalTargetingWithCachedId, idKey: "hb_cache_id"), cacheUrl)
        for key in normalTargeting.keys {
            var incompleteTargeting = normalTargeting
            incompleteTargeting[key] = nil
            XCTAssertNil(PBMWinNotifier.cacheUrl(fromTargeting: incompleteTargeting, idKey: "hb_uuid"))
        }
    }
    
    // MARK: - test no request is made
    
    func testNotification_noAdm_noNurl_noTargeting() {
        testNotification(adm: nil,
                         nurl: nil,
                         targeting: nil,
                         expectedUrls: [],
                         expectedMarkup: nil,
                         markupCallbackIndex: 0)
    }
    
    // MARK: - test requests to cache
    
    func testNotification_noAdm_noNurl_withTargeting_ok() {
        testNotification(adm: nil,
                         nurl: nil,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                         ],
                         expectedMarkup: someCachedMarkup,
                         markupCallbackIndex: 1)
    }
    func testNotification_noAdm_noNurl_withTargeting_error() {
        testNotification(adm: nil,
                         nurl: nil,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: nil),
                         ],
                         expectedMarkup: nil,
                         markupCallbackIndex: 1)
    }
    
    // MARK: - test requests to proper nurl
    
    func testNotification_noAdm_nurl_noTargeting_ok() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: nil,
                         expectedUrls: [
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someNurlMarkup,
                         markupCallbackIndex: 1)
    }
    func testNotification_noAdm_nurl_noTargeting_error() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: nil,
                         expectedUrls: [
                            (url: someNurl, adMarkup: nil),
                         ],
                         expectedMarkup: nil,
                         markupCallbackIndex: 1)
    }
    
    // MARK: - test nurl response ignored when cached ad is present
    
    func testNotification_noAdm_nurl_withTargeting_cacheOk_nurlOk() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someCachedMarkup,
                         markupCallbackIndex: 1)
    }
    
    func testNotification_noAdm_nurl_withTargeting_cacheOk_nurlError() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                            (url: someNurl, adMarkup: nil),
                         ],
                         expectedMarkup: someCachedMarkup,
                         markupCallbackIndex: 1)
    }
    
    // MARK: - test using nurl response on cache error
    
    func testNotification_noAdm_nurl_withTargeting_cacheError_nurlOk() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: nil),
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someNurlMarkup,
                         markupCallbackIndex: 2)
    }
    
    func testNotification_noAdm_nurl_withTargeting_cacheError_nurlError() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: nil),
                            (url: someNurl, adMarkup: nil),
                         ],
                         expectedMarkup: nil,
                         markupCallbackIndex: 2)
    }
    
    // MARK: - test both caches and nurl
    
    func testNotification_noAdm_nurl_withTargeting_cacheIdError_uuidError_nurlOk() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargetingFull,
                         expectedUrls: [
                            (url: cacheIdUrl, adMarkup: nil),
                            (url: cacheUrl, adMarkup: nil),
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someNurlMarkup,
                         markupCallbackIndex: 3)
    }
    
    func testNotification_noAdm_nurl_withTargeting_cacheIdError_uuidOk_nurlOk() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargetingFull,
                         expectedUrls: [
                            (url: cacheIdUrl, adMarkup: nil),
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someCachedMarkup,
                         markupCallbackIndex: 2)
    }
    
    func testNotification_noAdm_nurl_withTargeting_cacheIdOk_uuidOk_nurlOk() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargetingFull,
                         expectedUrls: [
                            (url: cacheIdUrl, adMarkup: someCachedIdJSON),
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someCachedIdMarkup,
                         markupCallbackIndex: 1)
    }
    
    // MARK: - test nurl/cache response ignored when adm is present
    
    // MARK: no URLs
    func testNotification_adm_noNurl_noTargeting() {
        testNotification(adm: someAdm,
                         nurl: nil,
                         targeting: nil,
                         expectedUrls: [],
                         expectedMarkup: someAdm,
                         markupCallbackIndex: 0)
    }
    
    // MARK: single URL
    func testNotification_adm_noNurl_withTargeting_ok() {
        testNotification(adm: someAdm,
                         nurl: nil,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                         ],
                         expectedMarkup: someAdm,
                         markupCallbackIndex: 0)
    }
    func testNotification_adm_nurl_noTargeting_ok() {
        testNotification(adm: someAdm,
                         nurl: someNurl,
                         targeting: nil,
                         expectedUrls: [
                            (url: someNurl, adMarkup: someNurlMarkup),
                         ],
                         expectedMarkup: someAdm,
                         markupCallbackIndex: 0)
    }
    
    // MARK: both URLs
    func testNotification_adm_nurl_withTargeting_ok() {
        testNotification(adm: someAdm,
                         nurl: someNurl,
                         targeting: nil,
                         expectedUrls: [
                            (url: someNurl, adMarkup: someNurlMarkup),
                            (url: cacheUrl, adMarkup: someCachedMarkup),
                         ],
                         expectedMarkup: someAdm,
                         markupCallbackIndex: 0)
    }
    func testNotification_adm_nurl_withTargeting_error() {
        testNotification(adm: someAdm,
                         nurl: someNurl,
                         targeting: nil,
                         expectedUrls: [
                            (url: someNurl, adMarkup: nil),
                            (url: cacheUrl, adMarkup: nil),
                         ],
                         expectedMarkup: someAdm,
                         markupCallbackIndex: 0)
    }
    
    // MARK: Macro replacement
    
    let bidPrice = 0.10903999999610946
    let markupWithMacros = "<html><div>You Won! This is a test bid</div><div>Price = ${AUCTION_PRICE}</div><div>Base64 Price = ${AUCTION_PRICE:B64}</div></html>"
    let markupWithReplacedMacros = "<html><div>You Won! This is a test bid</div><div>Price = 0.1090399999961095</div><div>Base64 Price = MC4xMDkwMzk5OTk5OTYxMDk1</div></html>"
    
    func testNotification_noAdm_nurl_markupWithMacros() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: nil),
                            (url: someNurl, adMarkup: markupWithMacros),
                         ],
                         expectedMarkup: markupWithReplacedMacros,
                         markupCallbackIndex: 2)
    }
    func testNotification_noAdm_cache_markupWithMacros() {
        testNotification(adm: nil,
                         nurl: someNurl,
                         targeting: normalTargeting,
                         expectedUrls: [
                            (url: cacheUrl, adMarkup: markupWithMacros),
                            (url: someNurl, adMarkup: nil),
                         ],
                         expectedMarkup: markupWithReplacedMacros,
                         markupCallbackIndex: 1)
    }
    
    // MARK: - Private helper
    
    private func testNotification(adm: String?,
                                  nurl: String?,
                                  targeting: [String: String]?,
                                  expectedUrls: [(url: String, adMarkup: String?)],
                                  expectedMarkup: String?,
                                  markupCallbackIndex: Int,
                                  file: StaticString = #file,
                                  line: UInt = #line)
    {
        let ortbBid = PBMORTBBid<PBMORTBBidExt>()
        ortbBid.price = NSNumber(value: bidPrice)
        ortbBid.adm = adm
        ortbBid.nurl = nurl
        if let targeting = targeting {
            let bidExtPrebid = PBMORTBBidExtPrebid()
            bidExtPrebid.targeting = targeting
            let bidExt = PBMORTBBidExt()
            bidExt.prebid = bidExtPrebid
            ortbBid.ext = bidExt
        }
        let bid = Bid(bid: ortbBid)
        
        let nextCallbackIndexBox = NSMutableArray(object: NSNumber(0))
        let connection = MockServerConnection(onDownload: expectedUrls.map { expectedDestination in { url, callback in
            nextCallbackIndexBox[0] = NSNumber(value: (nextCallbackIndexBox[0] as! NSNumber).intValue + 1)
            let response = PrebidServerResponse()
            if let nurlMarkup = expectedDestination.adMarkup {
                response.rawData = nurlMarkup.data(using: .utf8)
            } else {
                enum SomeFailure: Error { case someFailCode }
                response.error = SomeFailure.someFailCode
            }
            callback(response)
        }})
        
        let callbackCalled = expectation(description: "callback called")
        PBMWinNotifier.notifyThroughConnection(connection, winning: bid) { resultMarkup in
            let callbackIndex = (nextCallbackIndexBox[0] as! NSNumber).intValue;
            XCTAssertEqual(callbackIndex, markupCallbackIndex)
            nextCallbackIndexBox[0] = NSNumber(value: callbackIndex + 1)
            XCTAssertEqual(resultMarkup, expectedMarkup, file: file, line: line)
            callbackCalled.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

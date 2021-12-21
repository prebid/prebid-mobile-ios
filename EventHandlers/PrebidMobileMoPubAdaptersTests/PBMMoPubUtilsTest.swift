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

class PBMMoPubUtilsTest: XCTestCase, RawWinningBidFabricator {
    
    var adView: MPAdView?
    
    var mediationDelegate: PrebidMediationDelegate?
    
    override func setUp() {
        super.setUp()
        adView = MPAdView()
        mediationDelegate = MoPubMediationBannerUtils(mopubView: adView!)
    }
    
    func testAdObjectSetUpCleanUp() {
        
        let initialKeyWords = "key1,key2"
        let targetingInfo = [
            "hb_pb": "0.10",
            "hb_size": "320x50"
        ];
        let sortedKeywords = ["hb_pb:0.10", "hb_size:320x50", "key1", "key2"]
        let rawBid = makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
        let bid = Bid(bid: rawBid)
        let configId = "configId"
        
        adView!.keywords = initialKeyWords
        
        guard mediationDelegate!.setUpAdObject(configId: configId,
                                               configIdKey: PBMMediationConfigIdKey,
                                               targetingInfo: targetingInfo,
                                               extrasObject: bid,
                                               extrasObjectKey: PBMMediationAdUnitBidKey) else {
            XCTFail()
            return
        }
        
        let bidKeywords = adView!.keywords?.components(separatedBy: ",").sorted()
        
        XCTAssertEqual(bidKeywords, sortedKeywords)
        XCTAssertEqual(adView!.localExtras?[PBMMediationAdUnitBidKey] as! Bid, bid)
        XCTAssertEqual(adView!.localExtras?[PBMMediationConfigIdKey] as! String, configId)
        
        mediationDelegate!.cleanUpAdObject()
        
        XCTAssertEqual(adView!.keywords, initialKeyWords)
        XCTAssertEqual(adView!.localExtras?.count, 0)
    }
    
    // This test is not compilable due to changes in MoPubMediationUtils
    // TODO: Restore this test in https://github.com/prebid/prebid-mobile-ios/issues/431
//    func testFindNativeAd() {
//        let emptyExtras: [AnyHashable : Any] = [:]
//        let errorExpectation = expectation(description: "Error finding native ad expectation")
//        mediationDelegate.findNativeAd(emptyExtras) { _, error in
//            if error != nil {
//                errorExpectation.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 0.1)
//
//        let configId = "config-id"
//        let markupString = """
//{"assets": [{"required": 1, "title": { "text": "OpenX (Title)" }}],
//"link": {"url": "http://www.openx.com"}}
//"""
//        let rawBid = makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
//        let bid = Bid(bid: rawBid)
//        let responseInfo = DemandResponseInfo(fetchDemandResult: .ok, bid: bid, configId: configId) {
//            $1(markupString)
//        }
//        let targetingInfo = [
//            "hb_pb": "0.10",
//        ];
//
//        let adObject = MoPubAdObject()
//        guard mediationDelegate.setUpAdObject(adObject,
//                                       configID: configId,
//                                       targetingInfo: targetingInfo,
//                                       extraObject: responseInfo,
//                                       forKey: PBMMoPubAdNativeResponseKey) else {
//            XCTFail()
//            return
//        }
//
//        let successExpectation = expectation(description: "Success finding Native Ad expectation")
//        mediationDelegate.findNativeAd(adObject.localExtras!) { nativeAd, _ in
//            if nativeAd != nil {
//                successExpectation.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 0.1)
//    }
}

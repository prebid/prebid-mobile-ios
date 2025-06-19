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

class PBMORTBTest: XCTestCase {
    
    // MARK: - ORTB Response
    
    func testBidToJsonString() {
        let bid = ORTBBid<[String : Any]>(bidID: "test-bid-id-1",
                                             impid: "62B86D48-D7FA-4190-8F4E-65A170A731E6",
                                             price: 0.10903999999610946)
        
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        codeAndDecode(abstract: bid, expectedString: "{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}") { dic in
            ORTBBid(jsonDictionary: dic) { $0 }
        }
    }
    
    func testSeatBidToJsonString() {
        let bid = ORTBBid<[String : Any]>(bidID: "test-bid-id-1",
                                             impid: "62B86D48-D7FA-4190-8F4E-65A170A731E6",
                                             price: 0.10903999999610946)
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        let seatbid = ORTBSeatBid<[String : Any], [String : Any]>(bid: [bid])
        seatbid.bid = [bid]
        seatbid.seat = "openx"
        
        codeAndDecode(abstract: seatbid, expectedString: "{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}") { dic in
            ORTBSeatBid(jsonDictionary: dic, extParser: { $0 }, bidExtParser: { $0 })
        }
    }
    
    func testBidResponseToJsonString() {
        let bid = ORTBBid<[String : Any]>(bidID: "test-bid-id-1",
                                             impid: "62B86D48-D7FA-4190-8F4E-65A170A731E6",
                                             price: 0.10903999999610946)
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        let seatbid = ORTBSeatBid<[String : Any], [String : Any]>(bid: [bid])
        seatbid.bid = [bid]
        seatbid.seat = "openx"
        
        let response = ORTBBidResponse<[String : Any], [String : Any], [String : Any]>(
            requestID: "CCF0B31C-1813-43C5-A365-C12C785BA3D2"
        )
        response.ext = ["a": "t", "y": ["e": ["0": "7"], "w": "s"]]
        response.cur = "USD"
        response.seatbid = [seatbid]
        
        codeAndDecode(abstract: response, expectedString: "{\"cur\":\"USD\",\"ext\":{\"a\":\"t\",\"y\":{\"e\":{\"0\":\"7\"},\"w\":\"s\"}},\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}]}") { dic in
            ORTBBidResponse(jsonDictionary: dic, extParser: { $0 }, seatBidExtParser: { $0 }, bidExtParser: { $0 })
        }
    }
    
    // MARK: - Prebid ext
    
    func testPrebidCacheBids() {
        let bids = ORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        codeAndDecode(abstract: bids, expectedString: "{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"}")
    }
    
    func testPrebidCache() {
        let cache = ORTBBidExtPrebidCache()
        let bids = ORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = bids
        
        codeAndDecode(abstract: cache, expectedString: "{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"}")
    }
    
    func testBidExtPrebid() {
        let prebid = ORTBBidExtPrebid()
        let cache = ORTBBidExtPrebidCache()
        let bids = ORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = bids
        
        prebid.cache = cache
        prebid.targeting = [
            "hb_bidder": "openx",
            "hb_cache_host": "prebid.devint.openx.net",
            "hb_cache_path": "/cache",
            "hb_cache_id": "32541b8f-5d49-446d-ae26-18629273a6fe",
        ]
        prebid.type = "banner"
        
        codeAndDecode(abstract: prebid, expectedString: "{\"cache\":{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\"},\"type\":\"banner\"}")
    }
    
    func testBidExt() {
        let ext = ORTBBidExt()
        let prebid = ORTBBidExtPrebid()
        let cache = ORTBBidExtPrebidCache()
        let bids = ORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = bids
        
        prebid.cache = cache
        prebid.targeting = [
            "hb_bidder": "openx",
            "hb_cache_host": "prebid.devint.openx.net",
            "hb_cache_path": "/cache",
            "hb_cache_id": "32541b8f-5d49-446d-ae26-18629273a6fe",
        ]
        prebid.type = "banner"
        
        ext.prebid = prebid
        ext.bidder = [
            "ad_ox_cats": [
                2,
            ],
            "agency_id": "agency_10",
            "brand_id": "brand_10",
            "buyer_id": "buyer_10",
            "matching_ad_id": [
                "campaign_id": 1,
                "creative_id": 3,
                "placement_id": 2,
            ],
            "next_highest_bid_price": 0.099,
        ]
        
        codeAndDecode(abstract: ext, expectedString: "{\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099000000000000005},\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\"},\"type\":\"banner\"}}")
    }
    
    func testBidResponseExt() {
        let ext = ORTBBidResponseExt()
        
        ext.responsetimemillis = [
            "openx": 16,
        ]
        ext.tmaxrequest = 3000
        
        let extPrebid = ORTBBidResponseExtPrebid()
        
        let passthrough = ORTBExtPrebidPassthrough()
        
        let sdkConfiguration = PBMORTBSDKConfiguration()
        sdkConfiguration.cftBanner = 42
        sdkConfiguration.cftPreRender = 4242
        
        passthrough.sdkConfiguration = sdkConfiguration
        passthrough.type = "prebidmobilesdk"
        
        extPrebid.passthrough = [passthrough]
        
        ext.extPrebid = extPrebid
        
        codeAndDecode(abstract: ext, expectedString: "{\"prebid\":{\"passthrough\":[{\"sdkconfiguration\":{\"cftbanner\":42,\"cftprerender\":4242},\"type\":\"prebidmobilesdk\"}]},\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000}")
    }
    
    // MARK: - Skadn ext
    
    func testExtSkadnWithFidelities() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        
        let nonce0 = skadn.fidelities!.filter({ $0.fidelity == 0 }).first!.nonce!.uuidString
        let nonce1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!.nonce!.uuidString
        
        codeAndDecode(abstract: skadn, expectedString:  "{\"campaign\":45,\"fidelities\":[{\"fidelity\":0,\"nonce\":\"\(nonce0)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406342},{\"fidelity\":1,\"nonce\":\"\(nonce1)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406341}],\"itunesitem\":123456789,\"network\":\"cDkw7geQsH.skadnetwork\",\"sourceapp\":880047117,\"version\":\"2.2\"}")
    }
    
    func testExtSkadnSKOverlay_v4_0() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities_version_4_0_SKOverlay()
        let nonce0 = skadn.fidelities!.filter({ $0.fidelity == 0 }).first!.nonce!.uuidString
        let nonce1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!.nonce!.uuidString
        
        codeAndDecode(abstract: skadn, expectedString:  "{\"fidelities\":[{\"fidelity\":0,\"nonce\":\"\(nonce0)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406342},{\"fidelity\":1,\"nonce\":\"\(nonce1)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406341}],\"itunesitem\":123456789,\"network\":\"cDkw7geQsH.skadnetwork\",\"skoverlay\":{\"delay\":10,\"dismissible\":1,\"endcarddelay\":20,\"pos\":1},\"sourceapp\":880047117,\"sourceidentifier\":\"1234\",\"version\":\"4.0\"}")
    }
    
    // MARK: - Prebid response
    
    func testPrebidResponse() {
        let cacheBids = ORTBBidExtPrebidCacheBids()
        cacheBids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        cacheBids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        let cache = ORTBBidExtPrebidCache()
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = cacheBids
        
        let prebid = ORTBBidExtPrebid()
        prebid.cache = cache
        prebid.targeting = [
            "hb_bidder": "openx",
            "hb_cache_host": "prebid.devint.openx.net",
            "hb_cache_path": "/cache",
            "hb_cache_id": "32541b8f-5d49-446d-ae26-18629273a6fe",
        ]
        prebid.type = "banner"
        
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        
        let bidExt = ORTBBidExt()
        bidExt.prebid = prebid
        bidExt.bidder = [
            "ad_ox_cats": [
                2,
            ],
            "agency_id": "agency_10",
            "brand_id": "brand_10",
            "buyer_id": "buyer_10",
            "matching_ad_id": [
                "campaign_id": 1,
                "creative_id": 3,
                "placement_id": 2,
            ],
            "next_highest_bid_price": 0.099,
        ]
        bidExt.skadn = skadn
        
        let bid = ORTBBid<ORTBBidExt>(bidID: "test-bid-id-1",
                                            impid: "62B86D48-D7FA-4190-8F4E-65A170A731E6",
                                            price: 0.10903999999610946)
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = bidExt
        
        let seatbid = ORTBSeatBid<[String : Any], ORTBBidExt>(bid: [bid])
        seatbid.seat = "openx"
        
        let responseExt = ORTBBidResponseExt()
        responseExt.responsetimemillis = [
            "openx": 16,
        ]
        responseExt.tmaxrequest = 3000
        
        let response = ORTBBidResponse<ORTBBidResponseExt, [String : Any], ORTBBidExt>(
            requestID: "CCF0B31C-1813-43C5-A365-C12C785BA3D2"
        )
        response.ext = responseExt
        response.cur = "USD"
        response.seatbid = [seatbid]
        
        // MARK: validation
        
        let nonce0 = skadn.fidelities!.filter({ $0.fidelity == 0 }).first!.nonce!.uuidString
        let nonce1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!.nonce!.uuidString
        
        codeAndDecode(abstract: response, expectedString: "{\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000},\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099000000000000005},\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\"},\"type\":\"banner\"},\"skadn\":{\"campaign\":45,\"fidelities\":[{\"fidelity\":0,\"nonce\":\"\(nonce0)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406342},{\"fidelity\":1,\"nonce\":\"\(nonce1)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"timestamp\":1594406341}],\"itunesitem\":123456789,\"network\":\"cDkw7geQsH.skadnetwork\",\"sourceapp\":880047117,\"version\":\"2.2\"}},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}]}") { dic in
            ORTBBidResponse(jsonDictionary: dic, extParser: ORTBBidResponseExt.init(jsonDictionary:), seatBidExtParser: { $0 }, bidExtParser: ORTBBidExt.init(jsonDictionary:))
        }
    }
    
    func testRewardedResponse() {
        let rewarded = ORTBRewardedConfiguration()
        
        rewarded.completion = ORTBRewardedCompletion()
        
        rewarded.completion?.banner = ORTBRewardedCompletionBanner()
        rewarded.completion?.banner?.time = 5
        rewarded.completion?.banner?.event = "rwdd"
        
        rewarded.completion?.video = ORTBRewardedCompletionVideo()
        rewarded.completion?.video?.time = 5
        rewarded.completion?.video?.playbackevent = "complete"
        
        rewarded.completion?.video?.endcard = ORTBRewardedCompletionVideoEndcard()
        rewarded.completion?.video?.endcard?.time = 5
        rewarded.completion?.video?.endcard?.event = "rwdd"
        
        rewarded.close = ORTBRewardedClose()
        rewarded.close?.action = "closebutton"
        rewarded.close?.postrewardtime = 5
        
        rewarded.reward = ORTBRewardedReward()
        rewarded.reward?.type = "coins"
        rewarded.reward?.count = 5
        
        codeAndDecode(abstract: rewarded, expectedString:  "{\"close\":{\"action\":\"closebutton\",\"postrewardtime\":5},\"completion\":{\"banner\":{\"event\":\"rwdd\",\"time\":5},\"video\":{\"endcard\":{\"event\":\"rwdd\",\"time\":5},\"playbackevent\":\"complete\",\"time\":5}},\"reward\":{\"count\":5,\"type\":\"coins\"}}")
    }

    
    // MARK: - Private helpers
    
    private func codeAndDecode<T : PBMJsonCodable>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line, decoder: (JsonDictionary) -> T?) {
        cloneAndCompare(abstract: abstract, expectedString: expectedString, file:file, line: line) { src in
            let dic = src.jsonDictionary
            return decoder(dic)!
        }
    }
    
    private func codeAndDecode<T : PBMJsonCodable>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line) {
        cloneAndCompare(abstract: abstract, expectedString: expectedString, file:file, line: line) { src in
            return T.init(jsonDictionary: src.jsonDictionary)!
        }
    }
    
    private func cloneAndCompare<T : PBMJsonCodable>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line, cloneMethod: (T) throws -> T) {
        
        guard #available(iOS 11.0, *) else {
            Log.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }
        
        do {
            //Make a copy of the object
            let newCodable = try cloneMethod(abstract)
            
            //Convert it to json
            let newJsonString = try newCodable.toJsonString()
            
            //Strings should match
            PBMAssertEq(newJsonString, expectedString, file:file, line:line)
        } catch {
            XCTFail("\(error)", file:file, line:line)
        }
    }
}

extension PBMORTBAbstract: PBMJsonCodable {
    public var jsonDictionary: [String : Any] {
        self.toJsonDictionary()
    }
}

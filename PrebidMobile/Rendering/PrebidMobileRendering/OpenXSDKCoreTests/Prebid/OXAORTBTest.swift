//
//  OXAORTBTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

class OXAORTBTest: XCTestCase {
    
    // MARK: - ORTB Response
    
    func testBidToJsonString() {
        let bid = OXMORTBBid<NSDictionary>()
        
        bid.bidID = "test-bid-id-1"
        bid.impid = "62B86D48-D7FA-4190-8F4E-65A170A731E6"
        bid.price = 0.10903999999610946
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        codeAndDecode(abstract: bid, expectedString: "{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}") { dic in
            OXMORTBBid(jsonDictionary: dic) { $0 as NSDictionary }
        }
    }
    
    func testSeatBidToJsonString() {
        let seatbid = OXMORTBSeatBid<NSDictionary, NSDictionary>()
        
        let bid = OXMORTBBid<NSDictionary>()
        
        bid.bidID = "test-bid-id-1"
        bid.impid = "62B86D48-D7FA-4190-8F4E-65A170A731E6"
        bid.price = 0.10903999999610946
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        seatbid.bid = [bid]
        seatbid.seat = "openx"
        
        codeAndDecode(abstract: seatbid, expectedString: "{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}") { dic in
            OXMORTBSeatBid(jsonDictionary: dic, extParser: { $0 as NSDictionary }, bidExtParser: { $0 as NSDictionary })
        }
    }
    
    func testBidResponseToJsonString() {
        let response = OXMORTBBidResponse<NSDictionary, NSDictionary, NSDictionary>()
        
        let seatbid = OXMORTBSeatBid<NSDictionary, NSDictionary>()
        
        let bid = OXMORTBBid<NSDictionary>()
        
        bid.bidID = "test-bid-id-1"
        bid.impid = "62B86D48-D7FA-4190-8F4E-65A170A731E6"
        bid.price = 0.10903999999610946
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = ["q": "l", "z": "m", "n": ["r", "f"], "u": ["v": "w"]]
        
        seatbid.bid = [bid]
        seatbid.seat = "openx"
        
        response.requestID = "CCF0B31C-1813-43C5-A365-C12C785BA3D2"
        response.ext = ["a": "t", "y": ["e": ["0": "7"], "w": "s"]]
        response.cur = "USD"
        response.seatbid = [seatbid]
        
        codeAndDecode(abstract: response, expectedString: "{\"cur\":\"USD\",\"ext\":{\"a\":\"t\",\"y\":{\"e\":{\"0\":\"7\"},\"w\":\"s\"}},\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"n\":[\"r\",\"f\"],\"q\":\"l\",\"u\":{\"v\":\"w\"},\"z\":\"m\"},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}]}") { dic in
            OXMORTBBidResponse(jsonDictionary: dic, extParser: { $0 as NSDictionary }, seatBidExtParser: { $0 as NSDictionary }, bidExtParser: { $0 as NSDictionary })
        }
    }
    
    // MARK: - Prebid ext
    
    func testPrebidCacheBids() {
        let bids = OXAORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        codeAndDecode(abstract: bids, expectedString: "{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"}")
    }
    
    func testPrebidCache() {
        let cache = OXAORTBBidExtPrebidCache()
        let bids = OXAORTBBidExtPrebidCacheBids()
        
        bids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        bids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = bids
        
        codeAndDecode(abstract: cache, expectedString: "{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"}")
    }
    
    func testBidExtPrebid() {
        let prebid = OXAORTBBidExtPrebid()
        let cache = OXAORTBBidExtPrebidCache()
        let bids = OXAORTBBidExtPrebidCacheBids()
        
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
        let ext = OXAORTBBidExt()
        let prebid = OXAORTBBidExtPrebid()
        let cache = OXAORTBBidExtPrebidCache()
        let bids = OXAORTBBidExtPrebidCacheBids()
        
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
        let ext = OXAORTBBidResponseExt()
        
        ext.responsetimemillis = [
            "openx": 16,
        ]
        ext.tmaxrequest = 3000
        
        codeAndDecode(abstract: ext, expectedString: "{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000}")
    }
    
    // MARK: - Skadn ext
    
    func testExtSkadn() {
        let skadn = createSkadnExt()
        
        codeAndDecode(abstract: skadn, expectedString: "{\"campaign\":45,\"itunesitem\":123456789,\"network\":\"cDkw7geQsH.skadnetwork\",\"nonce\":\"\(skadn.nonce!.uuidString)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"sourceapp\":880047117,\"timestamp\":1594406341,\"version\":\"2.0\"}")
    }
    
    // MARK: - Prebid response
    
    func testPrebidResponse() {
        let response = OXMORTBBidResponse<OXAORTBBidResponseExt, NSDictionary, OXAORTBBidExt>()
        let seatbid = OXMORTBSeatBid<NSDictionary, OXAORTBBidExt>()
        let bid = OXMORTBBid<OXAORTBBidExt>()
        
        // MARK: bid.ext
        
        let bidExt = OXAORTBBidExt()
        let prebid = OXAORTBBidExtPrebid()
        let cache = OXAORTBBidExtPrebidCache()
        let cacheBids = OXAORTBBidExtPrebidCacheBids()
        
        cacheBids.url = "prebid.devint.openx.net/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe"
        cacheBids.cacheId = "32541b8f-5d49-446d-ae26-18629273a6fe"
        
        cache.key = "kkk"
        cache.url = "some/url"
        cache.bids = cacheBids
        
        prebid.cache = cache
        prebid.targeting = [
            "hb_bidder": "openx",
            "hb_cache_host": "prebid.devint.openx.net",
            "hb_cache_path": "/cache",
            "hb_cache_id": "32541b8f-5d49-446d-ae26-18629273a6fe",
        ]
        prebid.type = "banner"
        
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
        let skadn = createSkadnExt()
        bidExt.skadn = skadn
        
        // MARK: response.ext
        
        let responseExt = OXAORTBBidResponseExt()
        
        responseExt.responsetimemillis = [
            "openx": 16,
        ]
        responseExt.tmaxrequest = 3000
        
        // MARK: response
        
        bid.bidID = "test-bid-id-1"
        bid.impid = "62B86D48-D7FA-4190-8F4E-65A170A731E6"
        bid.price = 0.10903999999610946
        bid.adm = "<html><div>You Won! This is a test bid</div></html>"
        bid.adid = "test-ad-id-12345"
        bid.adomain = ["openx.com"]
        bid.crid = "test-creative-id-1"
        bid.w = 300
        bid.h = 250
        bid.ext = bidExt
        
        seatbid.bid = [bid]
        seatbid.seat = "openx"
        
        response.requestID = "CCF0B31C-1813-43C5-A365-C12C785BA3D2"
        response.ext = responseExt
        response.cur = "USD"
        response.seatbid = [seatbid]
        
        // MARK: validation
        
        codeAndDecode(abstract: response, expectedString: "{\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000},\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099000000000000005},\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"kkk\",\"url\":\"some\\/url\"},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\"},\"type\":\"banner\"},\"skadn\":{\"campaign\":45,\"itunesitem\":123456789,\"network\":\"cDkw7geQsH.skadnetwork\",\"nonce\":\"\(skadn.nonce!.uuidString)\",\"signature\":\"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==\",\"sourceapp\":880047117,\"timestamp\":1594406341,\"version\":\"2.0\"}},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}]}") { dic in
            OXMORTBBidResponse(jsonDictionary: dic, extParser: OXAORTBBidResponseExt.init(jsonDictionary:), seatBidExtParser: { $0 as NSDictionary }, bidExtParser: OXAORTBBidExt.init(jsonDictionary:))
        }
    }
    
    // MARK: - Private helpers
    
    private func codeAndDecode<T : OXMORTBAbstract>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line, decoder: (JsonDictionary) -> T?) {
        cloneAndCompare(abstract: abstract, expectedString: expectedString, file:file, line: line) { src in
            let dic = src.toJsonDictionary()
            return decoder(dic)!
        }
    }
    
    private func codeAndDecode<T : OXMORTBAbstract>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line) {
        cloneAndCompare(abstract: abstract, expectedString: expectedString, file:file, line: line) { src in
            return src.copy() as! T
        }
    }
    
    private func cloneAndCompare<T : OXMORTBAbstract>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line, cloneMethod: (T) throws -> T) {

        guard #available(iOS 11.0, *) else {
            OXMLog.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }
        
        do {
            //Make a copy of the object
            let newCodable = try cloneMethod(abstract)
            
            //Convert it to json
            let newJsonString = try newCodable.toJsonString()
            
            //Strings should match
            OXMAssertEq(newJsonString, expectedString, file:file, line:line)
        } catch {
            XCTFail("\(error)", file:file, line:line)
        }
    }
    
    private func createSkadnExt() -> OXAORTBBidExtSkadn {
        let skadn = OXAORTBBidExtSkadn()
        
        skadn.version = "2.0"
        skadn.network = "cDkw7geQsH.skadnetwork"
        skadn.campaign = 45
        skadn.itunesitem = 123456789
        skadn.nonce = UUID()
        skadn.sourceapp = 880047117
        skadn.timestamp = 1594406341
        skadn.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        
        return skadn
    }
}

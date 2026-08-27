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

@testable @_spi(PBMInternal) import PrebidMobile

class PBMBidResponseTransformerTest: XCTestCase {
    
    func testInvalidAccountID() {
        let response = PBMBidResponseTransformer.invalidAccountIDResponse(accountID: "0689a263-318d-448b-a3d4-b02e8a709d9d")
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidAccountId() as NSError)
        }
    }
    
    func testInvalidConfigId() {
        let response = PBMBidResponseTransformer.invalidConfigIdResponse(configId: "b6260e2b-bc4c-4d10-bdb5-d1c2b6c0c97a")
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidConfigId() as NSError)
        }
    }
    
    func testInvalidSize() {
        let response = PBMBidResponseTransformer.invalidSizeResponse(impIndex: 0, formatIndex: 0)
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidSize() as NSError)
        }
    }
    
    func testServerError() {
        let messageBody = "Invalid request: some server reason, probably"
        let response = PBMBidResponseTransformer.serverErrorResponse
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.serverError(messageBody) as NSError)
        }
    }
    
    func testNoJsonDic() {
        let response = PBMBidResponseTransformer.nonJsonDicResponse
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.jsonDictNotFound() as NSError)
        }
    }
    
    func testOk() {
        let bidPrice: Float = 0.1091000000051168
        let response = PBMBidResponseTransformer.makeValidResponse(bidPrice: bidPrice)
        
        let bidResponse = try! PBMBidResponseTransformer.transform(response)
        XCTAssertNotNil(bidResponse)
        XCTAssertNotNil(bidResponse.winningBid)
        XCTAssertEqual(bidResponse.winningBid?.price, bidPrice)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertTrue(bidResponse.winningBid === bidResponse.allBids?[0])
    }
    
    func testZeroPriceBid() {
        let response = PBMBidResponseTransformer.makeValidResponse(bidPrice: 0)
        
        let bidResponse = try! PBMBidResponseTransformer.transform(response)
        XCTAssertNotNil(bidResponse)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertNotNil(bidResponse.winningBid)
    }
    
    func testRemoveBidsWithoutSuccessfulCache_uncachedBidRemoved() {
        let bidResponse = BidResponse(jsonDictionary: Self.uncachedBidResponseDictionary())
        
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 1)
        XCTAssertEqual(bidResponse.allBids?.count, 0)
        XCTAssertNil(bidResponse.winningBid)
        XCTAssertNil(bidResponse.targetingInfo)
    }
    
    func testRemoveBidsWithoutSuccessfulCache_cachedBidRemains() {
        let bidResponse = BidResponse(jsonDictionary: Self.cachedBidResponseDictionary())
        
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 0)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertNotNil(bidResponse.winningBid)
        XCTAssertEqual(bidResponse.targetingInfo?["hb_cache_id"], "cache-id")
    }
    
    func testRemoveBidsWithoutSuccessfulCache_mixedResponseOnlyCachedBidRemains() {
        var response = Self.cachedBidResponseDictionary()
        var uncachedBid = Self.bidDictionary(cache: nil, bidder: "uncached_bidder")
        uncachedBid["id"] = "uncached-bid-id"
        var seatbid = (response["seatbid"] as? [[String : Any]])?[0] ?? [:]
        var bids = seatbid["bid"] as? [[String : Any]] ?? []
        bids.append(uncachedBid)
        seatbid["bid"] = bids
        response["seatbid"] = [seatbid]
        
        let bidResponse = BidResponse(jsonDictionary: response)
        
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 1)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertEqual(bidResponse.targetingInfo?["hb_bidder"], "openx")
    }
    
    func testTargetingInfo_winningBidTargetingOverridesLaterBids() {
        var winningBid = Self.bidDictionary(cache: nil, bidder: "winning_bidder")
        Self.setTargetingValue("winning_value", forKey: "shared_key", in: &winningBid)
        
        var laterBid = Self.bidDictionary(cache: nil, bidder: "later_bidder")
        laterBid["id"] = "later-bid-id"
        Self.setTargetingValue("later_value", forKey: "shared_key", in: &laterBid)
        
        let bidResponse = BidResponse(jsonDictionary: [
            "id": "response-id",
            "seatbid": [
                [
                    "bid": [
                        winningBid,
                        laterBid
                    ],
                    "seat": "openx"
                ]
            ],
            "cur": "USD"
        ])
        
        XCTAssertEqual(bidResponse.targetingInfo?["hb_bidder"], "winning_bidder")
        XCTAssertEqual(bidResponse.targetingInfo?["shared_key"], "winning_value")
    }
    
    func testRemoveBidsWithoutSuccessfulCache_vastXmlCacheBidRemains() {
        let bidResponse = BidResponse(jsonDictionary: Self.cachedBidResponseDictionary(cacheKey: "vastXml"))
        
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 0)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertNotNil(bidResponse.winningBid)
    }
    
    func testRemoveBidsWithoutSuccessfulCache_lowercaseVastXmlCacheBidRemains() {
        let bidResponse = BidResponse(jsonDictionary: Self.cachedBidResponseDictionary(cacheKey: "vastxml"))
        
        XCTAssertEqual(bidResponse.removeBidsWithoutSuccessfulCache(), 0)
        XCTAssertEqual(bidResponse.allBids?.count, 1)
        XCTAssertNotNil(bidResponse.winningBid)
    }
    
    func testRealPrebidResponse() {
        let realResponseBody = "{\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"cache\":{\"key\":\"\",\"url\":\"\",\"bids\":{\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\",\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\"}},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_host_openx\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_id_openx\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000}}"
        
        let serverResponse = PBMBidResponseTransformer.buildResponse(realResponseBody)
        let response = try! PBMBidResponseTransformer.transform(serverResponse)
        let serializedResponse = try! response.rawResponse!.toJsonString()
        
        let sortedResponseBody = try! String(
            data: JSONSerialization.data(
                withJSONObject: JSONSerialization.jsonObject(with: realResponseBody.data(using: .utf8)!),
                options: .sortedKeys),
            encoding: .utf8
        )
        
        XCTAssertEqual(serializedResponse, sortedResponseBody)
    }
    
    func testMacroReplacement() {
        let rawPrice = "0.10903999999610946"
        
        let replacements = [
            "AUCTION_PRICE": "0.1090399999961095",
        ]
        
        let rawNurl = "\"https:\\/\\/some.server.com\\/?price=${AUCTION_PRICE}&base64price=${AUCTION_PRICE:B64}\""
        let rawAdm = "\"<html><div>You Won! This is a test bid<\\/div><div>Price = ${AUCTION_PRICE}<\\/div><div>Base64 Price = ${AUCTION_PRICE:B64}<\\/div><\\/html>\""
        
        let nurlSrc = "https://some.server.com/?price=${AUCTION_PRICE}&base64price=${AUCTION_PRICE:B64}"
        let admSrc = "<html><div>You Won! This is a test bid</div><div>Price = ${AUCTION_PRICE}</div><div>Base64 Price = ${AUCTION_PRICE:B64}</div></html>"
        
        let responseBody = "{\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":\(rawPrice),\"adm\":\(rawAdm),\"nurl\":\(rawNurl),\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"cache\":{\"key\":\"\",\"url\":\"\",\"bids\":{\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\",\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\"}},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_host_openx\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_id_openx\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000}}"
        
        let serverResponse = PBMBidResponseTransformer.buildResponse(responseBody)
        let response = try! PBMBidResponseTransformer.transform(serverResponse)
        
        func checkReplacements(keyPath: KeyPath<Bid, String?>, src: String) {
            var expectedResult = src
            for (key, value) in replacements {
                expectedResult = expectedResult.replacingOccurrences(of: "${\(key)}", with: value)
                let base64Value = value.data(using: .utf8)!.base64EncodedString()
                expectedResult = expectedResult.replacingOccurrences(of: "${\(key):B64}", with: base64Value)
            }
            XCTAssertEqual(response.winningBid![keyPath: keyPath], expectedResult)
        }
        
        checkReplacements(keyPath: \.adm, src: admSrc)
        checkReplacements(keyPath: \.nurl, src: nurlSrc)
    }
    
    private static func cachedBidResponseDictionary(cacheKey: String = "bids") -> [String : Any] {
        [
            "id": "response-id",
            "seatbid": [
                [
                    "bid": [
                        bidDictionary(
                            cache: [
                                cacheKey: [
                                    "url": "https://prebid-cache/cache?uuid=cache-id",
                                    "cacheId": "cache-id"
                                ]
                            ],
                            bidder: "openx"
                        )
                    ],
                    "seat": "openx"
                ]
            ],
            "cur": "USD"
        ]
    }
    
    private static func uncachedBidResponseDictionary() -> [String : Any] {
        [
            "id": "response-id",
            "seatbid": [
                [
                    "bid": [
                        bidDictionary(cache: nil, bidder: "openx")
                    ],
                    "seat": "openx"
                ]
            ],
            "cur": "USD"
        ]
    }
    
    private static func bidDictionary(cache: [String : Any]?, bidder: String) -> [String : Any] {
        // Keep hb_cache_id present when cache is nil to verify strict mode relies on ext.prebid.cache,
        // not targeting alone.
        var prebid: [String : Any] = [
            "targeting": [
                "hb_bidder": bidder,
                "hb_pb": "0.10",
                "hb_cache_id": "cache-id"
            ],
            "type": "banner"
        ]
        prebid["cache"] = cache
        
        return [
            "id": "test-bid-id",
            "impid": "test-imp-id",
            "price": 0.1,
            "adm": "<html></html>",
            "w": 300,
            "h": 250,
            "ext": [
                "prebid": prebid
            ]
        ]
    }
    
    private static func setTargetingValue(_ value: String, forKey key: String, in bid: inout [String : Any]) {
        var ext = bid["ext"] as? [String : Any] ?? [:]
        var prebid = ext["prebid"] as? [String : Any] ?? [:]
        var targeting = prebid["targeting"] as? [String : Any] ?? [:]
        targeting[key] = value
        prebid["targeting"] = targeting
        ext["prebid"] = prebid
        bid["ext"] = ext
    }
}

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

@testable import PrebidMobile

class PBMBidResponseTransformerTest: XCTestCase {
    
    func testInvalidAccountID() {
        let response = PBMBidResponseTransformer.invalidAccountIDResponse(accountID: "0689a263-318d-448b-a3d4-b02e8a709d9d")
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidAccountId as NSError)
        }
    }
    
    func testInvalidConfigId() {
        let response = PBMBidResponseTransformer.invalidConfigIdResponse(configId: "b6260e2b-bc4c-4d10-bdb5-d1c2b6c0c97a")
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidConfigId as NSError)
        }
    }
    
    func testInvalidSize() {
        let response = PBMBidResponseTransformer.invalidSizeResponse(impIndex: 0, formatIndex: 0)
        
        do {
            let _ = try PBMBidResponseTransformer.transform(response)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as NSError, PBMError.prebidInvalidSize as NSError)
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
            XCTAssertEqual(error as NSError, PBMError.jsonDictNotFound as NSError)
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
        XCTAssertNil(bidResponse.winningBid)
    }
    
    func testRealPrebidResponse() {
        let realResponseBody = "{\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"cache\":{\"key\":\"\",\"url\":\"\",\"bids\":{\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\",\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\"}},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_host_openx\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_id_openx\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000}}"
        
        // modified with JSON-ABC + Replaced '0.099' with '0.099000000000000005'
        let realResponseBodyAbc = "{\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":16},\"tmaxrequest\":3000},\"id\":\"CCF0B31C-1813-43C5-A365-C12C785BA3D2\",\"seatbid\":[{\"bid\":[{\"adid\":\"test-ad-id-12345\",\"adm\":\"<html><div>You Won! This is a test bid<\\/div><\\/html>\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"ext\":{\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099000000000000005},\"prebid\":{\"cache\":{\"bids\":{\"cacheId\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"url\":\"prebid.devint.openx.net\\/cache?uuid=32541b8f-5d49-446d-ae26-18629273a6fe\"},\"key\":\"\",\"url\":\"\"},\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_cache_host\":\"prebid.devint.openx.net\",\"hb_cache_host_openx\":\"prebid.devint.openx.net\",\"hb_cache_id\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_id_openx\":\"32541b8f-5d49-446d-ae26-18629273a6fe\",\"hb_cache_path\":\"\\/cache\",\"hb_cache_path_openx\":\"\\/cache\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"}},\"h\":250,\"id\":\"test-bid-id-1\",\"impid\":\"62B86D48-D7FA-4190-8F4E-65A170A731E6\",\"price\":0.10903999999610946,\"w\":300}],\"seat\":\"openx\"}]}"
        
        let serverResponse = PBMBidResponseTransformer.buildResponse(realResponseBody)
        let response = try! PBMBidResponseTransformer.transform(serverResponse)
        let serializedResponse = try! response.rawResponse?.toJsonString()
        
        XCTAssertEqual(realResponseBodyAbc, serializedResponse)
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
}

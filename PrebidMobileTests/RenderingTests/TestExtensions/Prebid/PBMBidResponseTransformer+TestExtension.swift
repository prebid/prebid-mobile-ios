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
import PrebidMobile

extension PBMBidResponseTransformer {
    static func invalidAccountIDResponse(accountID: String) -> PrebidServerResponse {
        return buildResponse("Invalid request: Stored Request with ID=\"\(accountID)\" not found.")
    }
    
    static func invalidConfigIdResponse(configId: String) -> PrebidServerResponse {
        return buildResponse("Invalid request: Stored Imp with ID=\"\(configId)\" not found.")
    }
    
    static func invalidSizeResponse(impIndex: Int, formatIndex: Int) -> PrebidServerResponse {
        return buildResponse("Invalid request: Request imp[\(impIndex)].banner.format[\(formatIndex)] should define *either* {w, h} (for static size requirements) *or* {wmin, wratio, hratio} (for flexible sizes) to be non-zero.")
    }
    
    static var serverErrorResponse: PrebidServerResponse {
        return buildResponse("Invalid request: some server reason, probably")
    }
    
    static var nonJsonDicResponse: PrebidServerResponse {
        return buildResponse("Some texty (non-JSON-ish) response here")
    }
    
    static var someValidResponse: PrebidServerResponse {
        return makeValidResponse(bidPrice: 0.1091000000051168)
    }
    
    static var noWinningBidResponse: PrebidServerResponse {
        return makeValidResponse(bidPrice: 0.1091000000051168, noWinningBidProperties: true)
    }
    
    static func makeValidResponse(bidPrice: Float, noWinningBidProperties: Bool = false) -> PrebidServerResponse {
        let winningBidFragment = noWinningBidProperties ? "" : "{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"8BBB0D42-5A73-45AC-B275-51B299A74C32\",\"price\":\(bidPrice),\"adm\":\"<html><div>You Won! This is a test bid</div></html>\",\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}"
        return buildResponse("{\"id\":\"B4A2D3F4-41B6-4D37-B68B-EE8893E85C31\",\"seatbid\":[\(winningBidFragment)],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":62}}}")
    }
    
    static func makeNativeValidResponse(bidPrice: Float, noWinningBidProperties: Bool = false) -> PrebidServerResponse {
        let winningBidFragment = noWinningBidProperties ? "" : "{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"8BBB0D42-5A73-45AC-B275-51B299A74C32\",\"price\":\(bidPrice),\"adm\":\"<html><div>You Won! This is a test bid</div></html>\",\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"native\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}"
        return buildResponse("{\"id\":\"B4A2D3F4-41B6-4D37-B68B-EE8893E85C31\",\"seatbid\":[\(winningBidFragment)],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":62}}}")
    }
    
    static func makeValidResponseWithNonWinningTargetingInfo() -> PrebidServerResponse {
        let winningBidFragment =  "{\n  \"bid\": [\n    {\n      \"id\": \"test_id_bid\",\n      \"impid\": \"test_imp\",\n      \"price\": 0,\n      \"ext\": {\n        \"origbidcpm\": 0,\n        \"prebid\": {\n          \"meta\": {},\n          \"targeting\": {\n            \"hb_bidder\": \"Test-Bidder-1\",\n            \"hb_source\": \"s2s\",\n          }\n        }\n      }\n    }\n  ],\n  \"seat\": \"Test-Bidder-1\"\n}"
        return buildResponse("{\"id\":\"B4A2D3F4-41B6-4D37-B68B-EE8893E85C31\",\"seatbid\":[\(winningBidFragment)],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":62}}}")
    }
    
    static func makeValidResponseWithCTF(bidPrice: Float, ctfBanner: Double, ctfPreRender: Double) -> PrebidServerResponse {
        let winningBidFragment = "{\"bid\":[{\"id\":\"test-bid-id-1\",\"impid\":\"8BBB0D42-5A73-45AC-B275-51B299A74C32\",\"price\":\(bidPrice),\"adm\":\"<html><div>You Won! This is a test bid</div></html>\",\"adid\":\"test-ad-id-12345\",\"adomain\":[\"openx.com\"],\"crid\":\"test-creative-id-1\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder\":\"openx\",\"hb_bidder_openx\":\"openx\",\"hb_env\":\"mobile-app\",\"hb_env_openx\":\"mobile-app\",\"hb_pb\":\"0.10\",\"hb_pb_openx\":\"0.10\",\"hb_size\":\"300x250\",\"hb_size_openx\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"ad_ox_cats\":[2],\"agency_id\":\"agency_10\",\"brand_id\":\"brand_10\",\"buyer_id\":\"buyer_10\",\"matching_ad_id\":{\"campaign_id\":1,\"creative_id\":3,\"placement_id\":2},\"next_highest_bid_price\":0.099}}}],\"seat\":\"openx\"}"
        return buildResponse("{\"id\":\"B4A2D3F4-41B6-4D37-B68B-EE8893E85C31\",\"seatbid\":[\(winningBidFragment)],\"cur\":\"USD\",\"ext\":{\"responsetimemillis\":{\"openx\":62},\"prebid\":{\"passthrough\":[{\"type\":\"prebidmobilesdk\", \"sdkconfiguration\":{\"cftbanner\":\(ctfBanner),\"cftprerender\":\(ctfPreRender)}}]}}}")
    }
    
    // MARK: - Private Helpers
    
    static func buildResponse(_ body: String) -> PrebidServerResponse {
        let result = PrebidServerResponse()
        if let data = body.data(using: .utf8) {
            result.rawData = data
            if let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                result.jsonDict = dic
            }
        }
        return result
    }
}

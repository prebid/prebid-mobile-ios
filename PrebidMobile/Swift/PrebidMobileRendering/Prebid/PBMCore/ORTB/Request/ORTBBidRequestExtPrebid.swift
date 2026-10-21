/*   Copyright 2018-2021 Prebid.org, Inc.

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

class ORTBBidRequestExtPrebid: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var storedRequestID: String?
    var dataBidders: [String]?
    var storedAuctionResponse: String?
    var storedBidResponses: [[String: String]]?
    // targeting and cache are write-only via API; not populated on decode (matches ObjC parity)
    var cache: NSMutableDictionary?
    var targeting: NSMutableDictionary = NSMutableDictionary()
    var sdkRenderers: [[String: Any]]?

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        storedRequestID       = (jsonDictionary["storedrequest"] as? [String: Any])?["id"] as? String
        dataBidders           = (jsonDictionary["data"] as? [String: Any])?["bidders"] as? [String]
        storedAuctionResponse = (jsonDictionary["storedauctionresponse"] as? [String: Any])?["id"] as? String
        storedBidResponses    = jsonDictionary["storedbidresponse"] as? [[String: String]]
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        guard let storedRequestID = storedRequestID else { return [:] }

        var result = [String: Any]()

        if let cache = cache, cache.count > 0 {
            result["cache"] = cache
        }

        result["storedrequest"] = ["id": storedRequestID]

        if let renderers = sdkRenderers, !renderers.isEmpty {
            result["sdk"] = ["renderers": renderers]
        }

        result["targeting"] = targeting

        if let bidders = dataBidders, !bidders.isEmpty {
            result["data"] = ["bidders": bidders]
        }

        if let storedAuctionResponse = storedAuctionResponse {
            result["storedauctionresponse"] = ["id": storedAuctionResponse]
        }

        if let storedBidResponses = storedBidResponses {
            result["storedbidresponse"] = storedBidResponses
        }

        return result
    }
}

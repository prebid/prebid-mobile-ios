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


class ORTBImpExtPrebid: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var storedRequestID: String?
    var isRewardedInventory: Bool = false
    var storedAuctionResponse: String?

    // MARK: - Init

    override init() {
        super.init()
    }

    
    required init(jsonDictionary: [String: Any]) {
        super.init()
        storedRequestID       = (jsonDictionary["storedrequest"] as? [String: Any])?["id"] as? String
        isRewardedInventory   = jsonDictionary["is_rewarded_inventory"] != nil
        storedAuctionResponse = (jsonDictionary["storedauctionresponse"] as? [String: Any])?["id"] as? String
    }

    // MARK: - PBMJsonEncodable

    
    var jsonDictionary: [String: Any] {
        guard let storedRequestID = storedRequestID else { return [:] }

        var dict = [String: Any]()
        dict["storedrequest"] = ["id": storedRequestID]
        if isRewardedInventory {
            dict["is_rewarded_inventory"] = 1
        }
        if let storedAuctionResponse = storedAuctionResponse {
            dict["storedauctionresponse"] = ["id": storedAuctionResponse]
        }
        return dict
    }
}

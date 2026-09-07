//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc(PBMBidResponseTransformer) @_spi(PBMInternal) public class BidResponseTransformer: NSObject {

    private override init() {
        super.init()
    }

    @objc(transformResponse:error:)
    public static func transform(_ response: PrebidServerResponse) throws -> BidResponse {
        let responseBody = String(data: response.rawData ?? Data(), encoding: .utf8) ?? ""
        if responseBody.contains("Invalid request") {
            throw classifyRequestError(responseBody)
        }
        guard let jsonDict = response.jsonDict else {
            throw PBMError.jsonDictNotFound()
        }
        return BidResponse(jsonDictionary: jsonDict)
    }

    private static func classifyRequestError(_ responseBody: String) -> NSError {
        if responseBody.contains("Stored Imp with ID") || responseBody.contains("No stored imp found") {
            return PBMError.prebidInvalidConfigId()
        }
        if responseBody.contains("Stored Request with ID") || responseBody.contains("No stored request found") {
            return PBMError.prebidInvalidAccountId()
        }
        if responseBody.contains("Invalid request: Request imp[0].banner.format")
            || responseBody.contains("Request imp[0].banner.format")
            || responseBody.contains("Unable to set interstitial size list") {
            return PBMError.prebidInvalidSize()
        }
        return PBMError.serverError(responseBody)
    }
}

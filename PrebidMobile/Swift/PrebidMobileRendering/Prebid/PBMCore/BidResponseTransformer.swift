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

    @available(*, unavailable)
    override init() {
        super.init()
    }

    @objc(transformResponse:error:)
    public static func transform(_ response: PrebidServerResponse) throws -> BidResponse {
        guard let jsonDict = response.jsonDict else {
            // Prebid Server rejects a request with a plaintext body, so only a non-JSON body is classified.
            // A valid bid whose markup happens to contain "Invalid request" must not be reported as an error.
            let responseBody = String(data: response.rawData ?? Data(), encoding: .utf8) ?? ""
            if responseBody.contains("Invalid request") {
                throw classifyRequestError(responseBody)
            }
            throw PBMError.jsonDictNotFound()
        }
        let bidResponse = BidResponse(jsonDictionary: jsonDict)
        // BidResponse leaves rawResponse nil when the body is not an ORTB bid response (no top-level "id").
        guard bidResponse.rawResponse != nil else {
            throw PBMError.responseDeserializationFailed()
        }
        return bidResponse
    }

    private static func classifyRequestError(_ responseBody: String) -> NSError {
        if responseBody.contains("Stored Imp with ID") || responseBody.contains("No stored imp found") {
            return PBMError.prebidInvalidConfigId()
        }
        if responseBody.contains("Stored Request with ID") || responseBody.contains("No stored request found") {
            return PBMError.prebidInvalidAccountId()
        }
        if responseBody.range(of: #"imp\[\d+\]\.banner\.format"#, options: .regularExpression) != nil
            || responseBody.contains("Unable to set interstitial size list") {
            return PBMError.prebidInvalidSize()
        }
        return PBMError.serverError(responseBody)
    }
}

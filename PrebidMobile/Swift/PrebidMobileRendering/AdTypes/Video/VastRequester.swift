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

// ObjC name preserved for the bridge; still called from PBMAdRequesterVAST.m and PBMVastAdsBuilder.m
@objc(PBMVastRequester) @_spi(PBMInternal) public
class VastRequester: NSObject {

    // Replaces the ObjC `AdRequestCallback` typedef, which only this class used.
    // Bridges to `void (^)(PrebidServerResponse * _Nullable, NSError * _Nullable)`.
    public typealias Completion = (PrebidServerResponse?, Error?) -> Void

    private static let vastContentType = "application/x-www-form-urlencoded"

    // `url` stays Optional even though the deleted ObjC header declared it nonnull: a nil
    // used to reach the completion as an error (via the failed `PBMURLComponents` init),
    // and that must not become a bridging trap.
    @objc(loadVastURL:connection:completion:)
    public static func loadVastURL(
        _ url: String?,
        connection: PrebidServerConnectionProtocol,
        completion: @escaping Completion
    ) {
        guard let urlComponents = PBMURLComponents(url: url, paramsDict: [:]) else {
            completion(nil, PBMError.error(description: "Failed to create PBMURLComponents",
                                           statusCode: .undefined))
            return
        }

        guard let data = urlComponents.argumentsString.data(using: .utf8) else {
            completion(nil, PBMError.error(description: "Unable to create Data from PBMURLComponents.argumentsString",
                                           statusCode: .undefined))
            return
        }

        connection.post(
            urlComponents.urlString,
            contentType: vastContentType,
            data: data,
            timeout: PrebidConstants.CONNECTION_TIMEOUT_DEFAULT
        ) { serverResponse in
            if let error = serverResponse.error {
                completion(nil, error)
                return
            }

            if serverResponse.statusCode != 200 {
                // The status code is an arbitrary HTTP value, not a `PBMErrorCode`, so
                // it goes through the raw-`Int` initializer.
                completion(nil, PBMError(message: "Server responded with status code \(serverResponse.statusCode)",
                                         code: serverResponse.statusCode))
                return
            }

            guard serverResponse.rawData != nil else {
                completion(nil, PBMError.error(description: "No Data From Server",
                                               statusCode: .fileNotFound))
                return
            }

            completion(serverResponse, nil)
        }
    }
}

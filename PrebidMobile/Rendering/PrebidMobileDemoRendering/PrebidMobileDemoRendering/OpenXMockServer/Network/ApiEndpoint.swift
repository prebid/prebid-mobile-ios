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

import Alamofire

internal struct ApiEndpoint {
    static let host = "10.0.2.2"
    static let port = 8000
    private static let scheme = "https"
    private static let subpath = "/api"
    
    let path: String
    let queryItems: [String: String]

    static func addMock() -> ApiEndpoint {
        return ApiEndpoint(path: "add_mock")
    }
    
    static func setRandomNoBids() -> ApiEndpoint {
        return ApiEndpoint(path: "set_random_no_bids")
    }
    
    static func cancelRandomNoBids() -> ApiEndpoint {
        return ApiEndpoint(path: "cancel_random_no_bids")
    }
    
    static func getLogs() -> ApiEndpoint {
        return ApiEndpoint(path: "logs")
    }
    
    static func clearLogs() -> ApiEndpoint {
        return ApiEndpoint(path: "clear_logs")
    }
    
    static func bannerImage() -> ApiEndpoint {
        return ApiEndpoint(path: "image")
    }
    
    static func logEvents() -> ApiEndpoint {
        return ApiEndpoint(path: "events")
    }
}

extension ApiEndpoint {
    init(path: String) {
        self.init(path: path, queryItems: [:])
    }
}

extension ApiEndpoint: URLConvertible {
    func asURL() throws -> URL {
        var components = URLComponents()
        components.scheme = ApiEndpoint.scheme
        components.host = ApiEndpoint.host
        components.port = ApiEndpoint.port
        components.path = "\(ApiEndpoint.subpath)/\(path)"

        if !queryItems.isEmpty {
            components.queryItems = queryItems.map(URLQueryItem.init)
        }

        guard let url = components.url else {
            fatalError("URL failed to construct")
        }
        return url
    }
}

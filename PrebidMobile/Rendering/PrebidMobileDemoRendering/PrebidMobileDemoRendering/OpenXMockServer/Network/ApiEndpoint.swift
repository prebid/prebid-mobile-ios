//
//  ApiEndpoint.swift
//  MockServer
//
//  Created by Volodymyr Parunakian on 12/3/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

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

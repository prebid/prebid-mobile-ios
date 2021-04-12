//
//  NetworkManager.swift
//  MockServer
//
//  Created by Volodymyr Parunakian on 12/3/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

import Alamofire
import RxSwift

internal protocol NetworkManager {
    func makeRequestWithParsing<ResultType: Decodable>(method: Alamofire.HTTPMethod, endpoint: ApiEndpoint,
                                                       parameters: [String: Any], headers: [String: String]) -> Observable<ResultType>
}

extension NetworkManager {
    func makeRequestWithParsing<ResultType: Decodable>(method: Alamofire.HTTPMethod, endpoint: ApiEndpoint,
                                                       parameters: [String: Any] = [:]) -> Observable<ResultType> {
        return makeRequestWithParsing(method: method, endpoint: endpoint, parameters: parameters, headers: [:])
    }
}

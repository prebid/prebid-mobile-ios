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
import RxSwift

final internal class MockServerManager: NetworkManager {
    private let reachabilityManager = NetworkReachabilityManager(host: "https://10.0.2.2:8000")
    private let jsonDecoder: JSONDecoder

    init() {
        self.jsonDecoder = JSONDecoder()
    }
    
    private static var sessionManager: SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            ApiEndpoint.host: .disableEvaluation
        ]

        return SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()

    private func checkReachability() -> Observable<Void> {
        guard reachabilityManager?.isReachable ?? false else {
            return .error(NetworkError.noConnection)
        }
        return .just(())
    }
    
    private func parseErrorResponseIfNeeded(response: HTTPURLResponse, data: Any) throws {
        guard !(200..<300 ~= response.statusCode) else {
            return
        }
        throw NetworkError.unexpectedHttpError(code: response.statusCode)
    }
    
    private func makeRequestRaw(method: Alamofire.HTTPMethod, url: URLConvertible, parameters: [String: Any],
                                headers: [String: String]) -> Observable<(HTTPURLResponse, Data)> {
        let encoding: ParameterEncoding = URLEncoding.default
        return checkReachability()
            .flatMapLatest { [weak self] _ -> Observable<(HTTPURLResponse, Data)> in
                guard let strongSelf = self else {
                    return .empty()
                }
                return strongSelf.makeRequest(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            }
    }

    func makeRequestWithParsing<ResultType: Decodable>(method: Alamofire.HTTPMethod, endpoint: ApiEndpoint,
                                                       parameters: [String: Any], headers: [String: String]) -> Observable<ResultType> {
        return makeRequestRaw(method: method, url: endpoint, parameters: parameters,
                              headers: headers)
            .flatMapLatest { [weak self] response, data -> Observable<ResultType> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                try strongSelf.parseErrorResponseIfNeeded(response: response, data: data)
                do {
                    let parsedResult = try strongSelf.jsonDecoder.decode(ResultType.self, from: data)
                    return Observable.just(parsedResult)
                } catch {
                    return Observable.empty()
                }
            }
    }
    
    private func makeRequest(url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { observer -> Disposable in
            MockServerManager.sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseData { dataResponse in
                if let response = dataResponse.response, let data = dataResponse.data {
                    observer.onNext((response, data))
                } else {
                    observer.onError(NetworkError.parsingError(dataResponse.response))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}


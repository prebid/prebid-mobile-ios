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

import Combine
import Foundation

final internal class MockServerManager: NetworkManager {
    private let session: URLSession
    private let jsonDecoder = JSONDecoder()

    init(session: URLSession = mockSession) {
        self.session = session
    }

    // The local mock server uses a self-signed certificate. All other hosts use
    // URLSession's default trust evaluation, including redirected requests.
    private static let mockSession = URLSession(configuration: .default, delegate: MockServerTrustDelegate(), delegateQueue: nil)

    func makeRequestWithParsing<ResultType: Decodable>(method: HTTPMethod, endpoint: ApiEndpoint,
                                                       parameters: [String: Any], headers: [String: String]) -> AnyPublisher<ResultType, Error> {
        let request = Self.request(method: method, endpoint: endpoint, parameters: parameters, headers: headers)
        return session.dataTaskPublisher(for: request)
            .mapError { error -> Error in
                error.code == .notConnectedToInternet ? NetworkError.noConnection : NetworkError.otherError(error)
            }
            .receive(on: DispatchQueue.main)
            .tryMap { [jsonDecoder] data, response -> ResultType? in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.parsingError(nil)
                }
                guard (200..<300).contains(response.statusCode) else {
                    throw NetworkError.unexpectedHttpError(code: response.statusCode)
                }
                // Preserve the mock client's behavior for an undecodable response:
                // complete without a value, rather than fail the publisher.
                return try? jsonDecoder.decode(ResultType.self, from: data)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    static func request(method: HTTPMethod, endpoint: ApiEndpoint, parameters: [String: Any], headers: [String: String]) -> URLRequest {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        func encode(_ value: String) -> String { value.addingPercentEncoding(withAllowedCharacters: allowed)! }
        let query = parameters.sorted { $0.key < $1.key }.map { "\(encode($0.key))=\(encode(String(describing: $0.value)))" }.joined(separator: "&")
        var components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)!
        if method == .get, !query.isEmpty {
            components.percentEncodedQuery = [components.percentEncodedQuery, query].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "&")
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if method == .post {
            request.httpBody = Data(query.utf8)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
        }
        return request
    }
}

private final class MockServerTrustDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           challenge.protectionSpace.host == ApiEndpoint.host,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

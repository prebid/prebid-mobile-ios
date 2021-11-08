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

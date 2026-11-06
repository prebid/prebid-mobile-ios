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

public enum ResponseType: String {
    case regular
    case video
}

public final class PBMMockServer {
    private let requestManager = MockServerManager()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        
    }
    
    public func getLogs() {
        requestManager.makeRequestWithParsing(method: .get, endpoint: .getLogs())
            .sink(receiveCompletion: Self.logFailure, receiveValue: { (_: Requests) in })
            .store(in: &cancellables)
    }

    public func setRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .post, endpoint: .setRandomNoBids())
            .sink(receiveCompletion: Self.logFailure, receiveValue: { (_: Requests) in })
            .store(in: &cancellables)
    }

    public func cancelRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .get, endpoint: .cancelRandomNoBids())
            .sink(receiveCompletion: Self.logFailure, receiveValue: { (_: Requests) in })
            .store(in: &cancellables)
    }

    public func addMockResponse(auid: String, mock: String, type: ResponseType = .regular) {
        let parameters = ["auid": auid, "mock": mock, "type": type.rawValue]
        requestManager.makeRequestWithParsing(method: .post, endpoint: .addMock(),
                                              parameters: parameters)
            .sink(receiveCompletion: Self.logFailure, receiveValue: { (addMockResponse: AddMockResponse) in
                if addMockResponse.result {
                    print("Success adding mock")
                }
            })
            .store(in: &cancellables)
    }

    private static func logFailure(_ completion: Subscribers.Completion<Error>) {
        if case .failure(let error) = completion {
            print(error.localizedDescription)
        }
    }
}

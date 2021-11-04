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

import RxSwift

public enum ResponseType: String {
    case regular
    case video
}

public final class PBMMockServer {
    private let requestManager = MockServerManager()
    private let disposeBag = DisposeBag()
    
    public init() {
        
    }
    
    public func getLogs() {
        requestManager.makeRequestWithParsing(method: .get, endpoint: .getLogs())
            .catch { error -> Observable<Requests> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
    }
    
    public func setRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .post, endpoint: .setRandomNoBids())
            .catch { error -> Observable<Requests> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { _ in
            })
            .disposed(by: disposeBag)
    }
    
    public func cancelRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .get, endpoint: .cancelRandomNoBids())
            .catch { error -> Observable<Requests> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { _ in
            })
            .disposed(by: disposeBag)
    }
    
    public func addMockResponse(auid: String, mock: String, type: ResponseType = .regular) {
        let parameters = ["auid": auid, "mock": mock, "type": type.rawValue]
        requestManager.makeRequestWithParsing(method: .post, endpoint: .addMock(),
                                              parameters: parameters)
            .catch { error -> Observable<AddMockResponse> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { addMockResponse in
                if addMockResponse.result {
                    print("Success adding mock")
                }
            })
            .disposed(by: disposeBag)
    }
}

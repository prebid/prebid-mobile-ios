//
//  PBMMockServer.swift
//  MockServer
//
//  Created by Volodymyr Parunakian on 12/4/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

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
            .catchError { error -> Observable<Requests> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
    }
    
    public func setRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .post, endpoint: .setRandomNoBids())
            .catchError { error -> Observable<Requests> in
                print(error.localizedDescription)
                return .empty()
            }
            .subscribe(onNext: { _ in
            })
            .disposed(by: disposeBag)
    }
    
    public func cancelRandomNoBids() {
        requestManager.makeRequestWithParsing(method: .get, endpoint: .cancelRandomNoBids())
            .catchError { error -> Observable<Requests> in
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
            .catchError { error -> Observable<AddMockResponse> in
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

//
//  NetworkError.swift
//  MockServer
//
//  Created by Volodymyr Parunakian on 12/3/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

internal enum NetworkError: Error {
    case noConnection
    case parsingError(HTTPURLResponse?)
    case unexpectedHttpError(code: Int)
    case otherError(Error)

    var isNoConnectionError: Bool {
        if case .noConnection = self {
            return true
        }
        return false
    }
}

extension NetworkError: LocalizedError {
    var userDescription: String {
        var resultMessage: String?

        switch self {
        case .unexpectedHttpError(let code):
            resultMessage = "Unexpected HTTP error with code \(code)"
        case .noConnection:
            resultMessage = "Check your internet connection and try again"
        default:
            resultMessage = nil
        }
        
        return resultMessage ?? localizedDescription
    }
}

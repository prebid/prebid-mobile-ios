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

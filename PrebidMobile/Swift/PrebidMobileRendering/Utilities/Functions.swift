//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc @_spi(PBMInternal) public class Functions: NSObject {
    
    private override init() {
        super.init()
    }
    
    static func dictionary(from jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PBMError.error(description: "Could not convert jsonString to data: \(jsonString)")
        }
        return try dictionary(from: jsonData)
    }
    
    static func dictionary(from jsonData: Data) throws -> [String: Any] {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)

        guard let dict = jsonObject as? [String: Any] else {
            throw PBMError.error(description: "Invalid JSON data: \(jsonData)")
        }

        return dict
    }

    /// Parses a JSON string into `[String: Any]` while preserving the original
    /// decimal precision of numeric leaves. Numbers are stored as `NSDecimalNumber`,
    /// so subsequent serialization via `JSONSerialization.data(withJSONObject:)`
    /// emits the same decimal text the publisher provided.
    ///
    /// Use this for publisher-supplied JSON (e.g. arbitrary ORTB) where values like
    /// `0.05` or `0.1` must round-trip exactly. The default `dictionary(from:)`
    /// uses `JSONSerialization`, which decodes numbers as `Double` and loses
    /// precision for values that aren't exactly representable in IEEE-754.
    static func dictionaryPreservingDecimals(from jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PBMError.error(description: "Could not convert jsonString to data: \(jsonString)")
        }
        return try dictionaryPreservingDecimals(from: jsonData)
    }

    static func dictionaryPreservingDecimals(from jsonData: Data) throws -> [String: Any] {
        let node = try JSONDecoder().decode(JSONNode.self, from: jsonData)
        guard case let .object(dict) = node else {
            throw PBMError.error(description: "Invalid JSON data: top-level element is not an object")
        }
        return dict.mapValues { $0.unwrappedValue }
    }

    static func jsonString(from dictionary: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            throw PBMError.error(description: "Not valid JSON object: \(dictionary)")
        }
        
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys])
        guard let string = String(data: data, encoding: .utf8) else {
            throw PBMError.error(description: "Could not convert JsonDictionary: \(dictionary)")
        }
        
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - 
    
    @objc
    public static func checkCertificateChallenge(_ challenge: URLAuthenticationChallenge,
                                                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Check if mock server host
        guard challenge.protectionSpace.host == "10.0.2.2" else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        var certificateHost: String?
        if let serverTrust = challenge.protectionSpace.serverTrust,
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
           let summary = SecCertificateCopySubjectSummary(certificate) {
            certificateHost = summary as String
        }
        
        let credential = challenge.protectionSpace.serverTrust.map {
            URLCredential(trust: $0)
        }
        
        // Only allow when involving 10.0.2.2 mock server host
        if certificateHost == "10.0.2.2" {
            completionHandler(.useCredential, credential)
        }
    }
}

private enum JSONNode: Decodable {
    case null
    case bool(Bool)
    case number(NSDecimalNumber)
    case string(String)
    case array([JSONNode])
    case object([String: JSONNode])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            // Decode Bool before Decimal so that `true` / `false` aren't mapped to 1 / 0.
            self = .bool(bool)
        } else if let decimal = try? container.decode(Decimal.self) {
            self = .number(NSDecimalNumber(decimal: decimal))
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONNode].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONNode].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported JSON value"
            )
        }
    }

    var unwrappedValue: Any {
        switch self {
        case .null:                return NSNull()
        case .bool(let value):     return value
        case .number(let value):   return value
        case .string(let value):   return value
        case .array(let nodes):    return nodes.map { $0.unwrappedValue }
        case .object(let dict):    return dict.mapValues { $0.unwrappedValue }
        }
    }
}


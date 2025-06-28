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

@objc public class Functions: NSObject {
    
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

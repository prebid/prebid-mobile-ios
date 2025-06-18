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

public protocol PBMJsonDecodable {
    init?(jsonDictionary: [String : Any])
}

public protocol PBMJsonEncodable {
    var jsonDictionary: [String : Any] { get }
}

extension PBMJsonDecodable {
    public init?(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
        else {
            throw PBMError(message: "Could not parse string to JSON dictionary")
        }
        
        self.init(jsonDictionary: json)
    }
}

extension PBMJsonEncodable {
    public func toJsonString() throws -> String {
        let dictionary = jsonDictionary
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .sortedKeys)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PBMError(message: "Could not encode data to string")
        }
        
        return string
    }
}

typealias PBMJsonCodable = (PBMJsonDecodable & PBMJsonEncodable)

extension [String : Any]: PBMJsonCodable {
    public init(jsonDictionary: [String : Any]) {
        self = jsonDictionary
    }
    
    public var jsonDictionary: [String : Any] {
        self
    }
}



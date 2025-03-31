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

extension [String : Any] {
    
    subscript<T>(key key: String) -> T? {
        self[key] as? T
    }
    
    subscript<T>(key key: String, as type: T.Type) -> T? {
        self[key] as? T
    }
    
    func entity<T: PBMORTBAbstract>(key: String) -> T? {
        (self[key] as? [String : Any]).flatMap { T(jsonDictionary: $0) }
    }
    
    func array<T>(key: String, of type: T.Type) -> [T]? {
        (self[key] as? [Any])?.compactMap { $0 as? T }
    }
    
    func array<T: PBMORTBAbstract>(key: String, ofEntity: T.Type) -> [T]? {
        (self[key] as? [Any])?.compactMap {
            if let dict = $0 as? [String : Any],
               let entity = T(jsonDictionary: dict) {
                return entity
            }
            return nil
        }
    }
    
    func dictionary<T>(key: String, of type: T.Type) -> [String : T]? {
        (self[key] as? [String : Any])?.compactMapValues { $0 as? T }
    }
    
    func passthroughObjects(key: String) -> [PBMORTBExtPrebidPassthrough]? {
        // The prebid spec defines in various parts of the schema the "passthrough" key
        // which is supposed to map to a JSON object. However it was mistakenly implemented
        // as an array of objects in this SDK. To maintain backwards compatibility we still
        // check for the array of objects.
        let dictionaries: [[String : Any]]?
        switch self[key] {
            case let value as [String : Any]:
                dictionaries = [value]
            case let value as [Any]:
                dictionaries = value.compactMap { $0 as? [String : Any] }
            default:
                dictionaries = nil
        }
        
        return dictionaries?.map { PBMORTBExtPrebidPassthrough(jsonDictionary: $0) }.nilIfEmpty
    }
}

extension Array {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Dictionary {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}


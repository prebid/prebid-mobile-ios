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

struct JSONObject<Key: RawRepresentable> where Key.RawValue == String {
    private(set) var dict: [String : Any]
    
    init() {
        dict = [:]
    }
    
    init(_ dict: [String : Any]) {
        self.dict = dict
    }
    
    // MARK: Single Value
    
    subscript(_ key: Key) -> NSNumber? {
        get {
            dict[key.rawValue] as? NSNumber
        }
        
        set {
            dict[key.rawValue] = newValue
        }
    }
    
    subscript(_ key: Key) -> String? {
        get {
            dict[key.rawValue] as? String
        }
        
        set {
            dict[key.rawValue] = newValue
        }
    }
    
    subscript(_ key: Key) -> UUID? {
        get {
            (dict[key.rawValue] as? String).flatMap { UUID(uuidString: $0) }
        }
        
        set {
            dict[key.rawValue] = newValue?.uuidString
        }
    }
    
    subscript<T: PBMJsonCodable>(_ key: Key) -> T? {
        get {
            (dict[key.rawValue] as? [String : Any]).flatMap { T.init(jsonDictionary: $0) }
        }
        
        set {
            dict[key.rawValue] = newValue?.jsonDictionary
        }
    }
    
    subscript<T: PBMORTBAbstract>(_ key: Key) -> T? {
        get {
            (dict[key.rawValue] as? [String : Any]).flatMap { T.init(jsonDictionary: $0) }
        }
        
        set {
            dict[key.rawValue] = newValue?.toJsonDictionary()
        }
    }
    
    // MARK: Array
    
    @_disfavoredOverload
    subscript<T>(_ key: Key) -> [T]? {
        get {
            (dict[key.rawValue] as? [Any])?.compactMap { $0 as? T }
        }
        
        set {
            dict[key.rawValue] = newValue
        }
    }
    
    subscript<T: PBMORTBAbstract>(_ key: Key) -> [T]? {
        get {
            (dict[key.rawValue] as? [Any])?.compactMap {
                ($0 as? [String : Any]).flatMap { T.init(jsonDictionary: $0) }
            }
        }
        
        set {
            dict[key.rawValue] = newValue?.compactMap { $0.toJsonDictionary() }
        }
    }
    
    subscript<T: PBMJsonCodable>(_ key: Key) -> [T]? {
        get {
            (dict[key.rawValue] as? [Any])?.compactMap {
                ($0 as? [String : Any]).flatMap { T.init(jsonDictionary: $0) }
            }
        }
        
        set {
            dict[key.rawValue] = newValue?.compactMap { $0.jsonDictionary }
        }
    }
    
    // MARK: Object
    
    subscript<T>(_ key: Key) -> [String : T]? {
        get {
            (dict[key.rawValue] as? [String : Any])?.compactMapValues { $0 as? T }
        }
        
        set {
            dict[key.rawValue] = newValue
        }
    }
    
    func backwardsCompatiblePassthrough(key: Key) -> [ORTBExtPrebidPassthrough]? {
        // The prebid spec defines in various parts of the schema the "passthrough" key
        // which is supposed to map to a JSON object. However it was mistakenly implemented
        // as an array of objects in this SDK. To maintain backwards compatibility we still
        // check for the array of objects.
        let dictionaries: [[String : Any]]?
        switch dict[key.rawValue] {
            case let value as [String : Any]:
                dictionaries = [value]
            case let value as [Any]:
                dictionaries = value.compactMap { $0 as? [String : Any] }
            default:
                dictionaries = nil
        }
        
        return dictionaries?.compactMap { ORTBExtPrebidPassthrough(jsonDictionary: $0) }
    }
}

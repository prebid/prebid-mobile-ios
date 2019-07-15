/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

import Foundation

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
        var dict = [Key: Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

// MARK: - Clean a collection

extension Array where Element == Any {
    func getObjectWithoutEmptyValues() -> [Element]? {
        
        var result = self

        removeEntryWithoutValue(&result)

        return result.count > 0 ? result : nil
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    
    func getObjectWithoutEmptyValues() -> [Key: Value]? {
        var result = self
        
        removeEntryWithoutValue(&result)
        
        return result.count > 0 ? result : nil
    }
    
}

private func removeEntryWithoutValue(_ array: inout [Any]) {
    for (index, var value) in array.enumerated().reversed() {
        
        if var dictValue = value as? Dictionary<AnyHashable, Any> {
            removeEntryWithoutValue(&dictValue)
            array[index] = dictValue
            
            if dictValue.count == 0 {
                array.remove(at: index)
            }
            
        } else if var arrayValue = value as? Array<Any> {
            removeEntryWithoutValue(&arrayValue)
            array[index] = arrayValue
            
            if arrayValue.count == 0 {
                array.remove(at: index)
            }
        }
    }
}

private func removeEntryWithoutValue(_ dict: inout [AnyHashable: Any]) {
    
    for key in dict.keys {
        if var value = dict[key] {
            
            if var dictValue = value as? Dictionary<AnyHashable, Any> {
                removeEntryWithoutValue(&dictValue)
                dict[key] = dictValue
                
                if dictValue.count == 0 {
                    dict[key] = nil
                    
                }
            } else if var arrayValue = value as? Array<Any> {
                
                removeEntryWithoutValue(&arrayValue)
                dict[key] = arrayValue
                
                if arrayValue.count == 0 {
                    dict[key] = nil
                }
            }
        }
        
    }
}

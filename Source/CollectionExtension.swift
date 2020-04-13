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

extension Array where Element == Any {
    func getObjectWithoutEmptyValues() -> [Element]? {
        
        var result = self

        removeEntryWithoutValue(&result)

        return result.count > 0 ? result : nil
    }
}

extension Set {
    func toCommaSeparatedListString() -> String {
        return self.map({"\($0)"}).joined(separator: ",")
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension Dictionary where Value == Set<String> {
    mutating func addValue(_ value: String, forKey: Key) {
        
        var valueSet = self[forKey] ?? Set<String>()
        
        let isInserted = valueSet.insert((value)).inserted
        
        if isInserted {
            self[forKey] = valueSet
        }
    }
    
    func getCopyWhereValueIsArray() -> [Key: [String]] {
        var dictionary = [Key: [String]]()
        
        for (key, valueSet) in self {
            let valuerArray = Array(valueSet)
            dictionary[key] = valuerArray
        }
        
        return dictionary
    }
    
    func toCommaSeparatedListString() -> String {
        return toString(entrySeparator: ",", keyValueSeparator: "=")
    }
    
    func toString(entrySeparator: String, keyValueSeparator: String) -> String {
        
        var resultString = ""
        
        for (key, dictValues) in self {
            
            for value in dictValues {
                
                let keyValue = "\(key)\(keyValueSeparator)\(value)"
                
                if (resultString != "") {
                    resultString = "\(resultString)\(entrySeparator)\(keyValue)"
                } else {
                    resultString = keyValue
                }
            }
        }
        
        return resultString
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    
    func getObjectWithoutEmptyValues() -> [Key: Value]? {
        var result = self
        
        removeEntryWithoutValue(&result)
        
        return result.count > 0 ? result : nil
    }
    
    func toString(entrySeparator: String, keyValueSeparator: String) -> String {
        
        var resultString = ""
        
        for (key, value) in self {
            resultString += "\(key)\(keyValueSeparator)\(value)\(entrySeparator)"
        }
        
        if (resultString != "") {
            resultString.remove(at: resultString.index(before: resultString.endIndex))
        }
        
        return resultString
    }
    
}

extension Dictionary where Key == String, Value == String {
    func toString(entrySeparator: String, keyValueSeparator: String) -> String {
        return (self as Dictionary<AnyHashable, Any>).toString(entrySeparator: entrySeparator, keyValueSeparator: keyValueSeparator)
    }
}

extension Array where Element: SingleContainerInt {
    func toIntArray() -> [Int] {
        
        var result: [Int] = []

        for element in self {
            result.append(element.value)
        }

        return result
    }
}

//MARK: - private block

private func removeEntryWithoutValue(_ array: inout [Any]) {
    for (index, value) in array.enumerated().reversed() {
        
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
        } else if let stringValue = value as? String {
            if stringValue.isEmpty {
                array.remove(at: index)
            }
        }
    }
}

private func removeEntryWithoutValue(_ dict: inout [AnyHashable: Any]) {
    
    for key in dict.keys {
        if let value = dict[key] {
            
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
            } else if let stringValue = value as? String {
                if stringValue.isEmpty {
                    dict[key] = nil
                }
            }
        }
        
    }
}

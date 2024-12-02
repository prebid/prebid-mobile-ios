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
    func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
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

extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}

extension Dictionary where Key == String {
    
    /// Merges the current dictionary with another dictionary recursively,
    /// with options to control replacement behavior.
    ///
    /// - Parameters:
    ///   - otherDict: The dictionary to merge with the current dictionary.
    ///   - shouldReplace: A Boolean indicating whether to replace existing values in the
    ///     current dictionary with values from `otherDict`. Defaults to `false`.
    ///
    /// - Returns: A new dictionary that is the result of the merge operation.
    ///
    /// - Notes:
    ///   - Arrays with matching keys are concatenated and deduplicated (if possible).
    ///   - Nested dictionaries are merged recursively.
    func deepMerging(
        with otherDict: [String: Any],
        shouldReplace: Bool = false
    ) -> [String: Any] {
        var result: [String: Any] = self
        
        for (key, value) in otherDict {
            if let existingValue = result[key] {
                if shouldReplace {
                    result[key] = value
                } else {
                    if let existingArray = existingValue as? [Any], let newArray = value as? [Any] {
                        let mergedArray = existingArray + newArray
                        if let hashableMergedArray = mergedArray as? [AnyHashable] {
                            result[key] = hashableMergedArray.removingDuplicates()
                        } else {
                            result[key] = mergedArray
                        }
                    }
                    else if let existingDict = existingValue as? [String: Any],
                            let newDict = value as? [String: Any] {
                        result[key] = existingDict.deepMerging(
                            with: newDict,
                            shouldReplace: shouldReplace
                        )
                    }
                    else {
                        result[key] = value
                    }
                }
            }
            else {
                result[key] = value
            }
        }
        
        return result
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

extension Optional where Wrapped == NSNumber {
    var boolValue: Bool? {
        switch self {
        case 1: return true
        case 0: return false
        default: return nil
        }
    }
}

extension Optional where Wrapped == Bool {
    var nsNumberValue: NSNumber? {
        switch self {
        case true: return 1
        case false: return 0
        default: return nil
        }
    }
}

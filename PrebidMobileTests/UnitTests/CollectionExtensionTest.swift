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

import XCTest
@testable import PrebidMobile

class CollectionExtensionTest: XCTestCase {
    
    func testGetObjectWithoutEmptyValues() {
        //Test 1
        let node1111: NSMutableDictionary = [:]
        let node111: NSMutableDictionary = [:]
        node111["key111"] = node1111
        
        let node11: NSMutableDictionary = [:]
        node11["key11"] = node111
        
        let node1: NSMutableDictionary = [:]
        node1["key1"] = node11
        
        node1["emptyObject"] = "";
        let array: NSMutableArray = []
        array.add("");
        node1["emptyArray"] = array;
        
        let result1 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertNil(result1)
        
        //Test 2
        node1111["key1111"] = "value1111"
        
        let result2 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key1\":{\"key11\":{\"key111\":{\"key1111\":\"value1111\"}}}}", collectionToString(result2!))
        
        //Test 3
        node1111["key1111"] = nil
        
        let node121: NSMutableDictionary = [:]
        node121["key121"] = "value121"
        node11["key12"] = node121
        
        let result3 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key1\":{\"key12\":{\"key121\":\"value121\"}}}", collectionToString(result3!))
        
        //Test 4
        node11["key12"] = nil
        let node21: NSMutableArray = []
        node1["key2"] = node21
        let result4 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertNil(result4)
        
        //Test5
        node21.add("value21")
        let result5 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key2\":[\"value21\"]}", collectionToString(result5!))
        
        //Test6
        node21.removeObject(at: 0)
        let node211: NSMutableDictionary = [:]
        node21.add(node211)
        let result6 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertNil(result6)
        
        //Test7
        node211["key211"] = "value211"
        let result7 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key2\":[{\"key211\":\"value211\"}]}", collectionToString(result7!))
        
        //Test8
        node21.removeObject(at: 0)
        let node212: NSMutableArray = []
        node21.add(node212)
        let result8 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertNil(result8)
        
        //Test9
        let node31: NSMutableArray = []
        node1["key3"] = node31
        let node311: NSMutableDictionary = [:]
        node31.add(node311)
        let node312: NSMutableDictionary = [:]
        node312["key312"] = "value312"
        node31.add(node312)
        let result9 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key3\":[{\"key312\":\"value312\"}]}", collectionToString(result9!))
        
        //Test10
        let node313: NSMutableArray = []
        let node3131: NSMutableDictionary = [:]
        node3131["key3131"] = "value3131"
        node313.add(node3131)
        let node3132: NSMutableDictionary = [:]
        node313.add(node3132)
        node31.add(node313)
        let result10 = (node1 as! Dictionary).getObjectWithoutEmptyValues()
        XCTAssertEqual("{\"key3\":[{\"key312\":\"value312\"},[{\"key3131\":\"value3131\"}]]}", collectionToString(result10!))
    }
    
    func testSingleContainerIntToIntArray() {
        //given
        let array: [SingleContainerInt] = [1, 2, 5]
        
        //when
        let intArray = array.toIntArray()
        
        //then
        XCTAssertEqual(3, intArray.count)
        XCTAssertTrue(intArray.contains(1) && intArray.contains(2) && intArray.contains(5))
    }
    
    func testDeepMergeValues() {
        let dict1: [String: Any] = [
            "key1": "value1",
            "key2": "value2",
            "key4": [1,2,3],
            "key5": 0.1,
            "key6": "value6",
            "key7": ["nested1": "nested_value1", "nested2": "nested_value2"],
            "key8": ["nested1": "nested_value1", "nested2": ["deep_nested1": "deep_nested_value1", "deep_nested2": "deep_nested_value2"]]
        ]
        
        let dict2: [String: Any] = [
            "key2": "newValue2",
            "key3": "value3",
            "key4": [2,3,4,5],
            "key5": 1,
            "key6": 1.0,
            "key7": ["nested2": "another_nested_value2", "nested3": "nested_value3"],
            "key8": ["nested1": "another_nested_value1", "nested2": ["deep_nested1": "new_nested1", "another_deep_nested2": "another_deep_nested_value2"]]
        ]
        
        let result = dict1.deepMerging(with: dict2)
        
        XCTAssertEqual(result["key1"] as? String, "value1")
        XCTAssertEqual(result["key2"] as? String, "newValue2")
        XCTAssertEqual(result["key3"] as? String, "value3")
        XCTAssertEqual(result["key4"] as? [Int], [1,2,3,4,5])
        XCTAssertEqual(result["key5"] as? Int, 1)
        XCTAssertEqual(result["key6"] as? Double, 1.0)
        XCTAssertEqual(result["key7"] as? [String: String], ["nested1": "nested_value1", "nested2": "another_nested_value2", "nested3": "nested_value3"])
        XCTAssert(NSDictionary(dictionary: result["key8"] as! [String: Any]).isEqual(to: ["nested1": "another_nested_value1", "nested2":["deep_nested1": "new_nested1", "deep_nested2": "deep_nested_value2", "another_deep_nested2": "another_deep_nested_value2"]] as [String : Any]))
    }
    
    func testDeepMergeReplaceValues() {
        let dict1: [String: Any] = [
            "key1": "value1",
            "key2": "value2",
            "key4": [1,2,3],
            "key5": 0.1,
            "key6": "value6",
            "key7": ["nested1": "nested_value1", "nested2": "nested_value2"],
            "key8": ["nested1": "nested_value1", "nested2": ["deep_nested1": "deep_nested_value1", "deep_nested2": "deep_nested_value2"]]
        ]
        
        let dict2: [String: Any] = [
            "key2": "newValue2",
            "key3": "value3",
            "key4": [3,4,5],
            "key5": 1,
            "key6": 1.0,
            "key7": ["nested2": "another_nested_value2", "nested3": "nested_value3"],
            "key8": ["nested1": "another_nested_value1", "nested2": ["deep_nested1": "new_nested1", "another_deep_nested2": "another_deep_nested_value2"]]
        ]
        
        let result = dict1.deepMerging(with: dict2, shouldReplace: true)
        
        XCTAssertEqual(result["key1"] as? String, "value1")
        XCTAssertEqual(result["key2"] as? String, "newValue2")
        XCTAssertEqual(result["key3"] as? String, "value3")
        XCTAssertEqual(result["key4"] as? [Int], [3,4,5])
        XCTAssertEqual(result["key5"] as? Int, 1)
        XCTAssertEqual(result["key6"] as? Double, 1.0)
        XCTAssertEqual(result["key7"] as? [String: String], ["nested2": "another_nested_value2", "nested3": "nested_value3"])
        XCTAssert(NSDictionary(dictionary: result["key8"] as! [String: Any]).isEqual(to: ["nested1": "another_nested_value1", "nested2": ["deep_nested1": "new_nested1", "another_deep_nested2": "another_deep_nested_value2"]] as [String : Any]))
    }
    
    func testDeepMergeEmptyDictionary() {
        let dict1: [String: Any] = [:]
        let dict2: [String: Any] = [:]
        
        let merged = dict1.deepMerging(with: dict2)
        XCTAssertTrue(merged.isEmpty)
    }
    
    func testDeepMergeOneEmptyDictionary() {
        let dict1: [String: Any] = ["key1": "value1"]
        let dict2: [String: Any] = [:]
        
        let merged = dict1.deepMerging(with: dict2)
        XCTAssert(NSDictionary(dictionary: merged).isEqual(to: dict1))
        
        let merged2 = dict2.deepMerging(with: dict1)
        XCTAssert(NSDictionary(dictionary: merged2).isEqual(to: dict1))
    }
    
    func testDeepMergeIdenticalDictionaries() {
        let dict1: [String: Any] = ["key1": "value1", "key2": "value2"]
        let dict2: [String: Any] = ["key1": "value1", "key2": "value2"]
        
        let merged = dict1.deepMerging(with: dict2)
        XCTAssert(NSDictionary(dictionary: merged).isEqual(to: dict1))
    }
    
    func testDeepMergeArraysWithDuplicates() {
        let dict1: [String: Any] = ["key1": [1, 2, 3]]
        let dict2: [String: Any] = ["key1": [3, 4, 5]]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = ["key1": [1, 2, 3, 4, 5]]
        
        XCTAssertEqual(merged["key1"] as? [Int], expected["key1"] as? [Int])
    }
    
    func testDeepMergeDifferentValueTypes() {
        let dict1: [String: Any] = ["key1": 123]
        let dict2: [String: Any] = ["key1": "value1"]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = ["key1": "value1"]
        
        XCTAssert(NSDictionary(dictionary: merged).isEqual(to: expected))
    }
    
    func testDeepMergeReplaceArrayWithDictionary() {
        let dict1: [String: Any] = ["key1": [1, 2, 3]]
        let dict2: [String: Any] = ["key1": ["nestedKey": "value1"]]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = ["key1": ["nestedKey": "value1"]]
        
        XCTAssert(NSDictionary(dictionary: merged).isEqual(to: expected))
    }
    
    func testDeepMergeNestedDictionariesWithArrays() {
        let dict1: [String: Any] = ["key1": ["nestedKey": [1, 2]]]
        let dict2: [String: Any] = ["key1": ["nestedKey": [3, 4]]]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = ["key1": ["nestedKey": [1, 2, 3, 4]]]
        
        XCTAssert(NSDictionary(dictionary: merged["key1"] as! [String: Any]).isEqual(to: expected["key1"] as! [String: Any]))
    }
    
    func testDeepMergePrimitives() {
        let dict1: [String: Any] = ["key1": 123]
        let dict2: [String: Any] = ["key1": "value"]
        
        let merged = dict1.deepMerging(with: dict2)
        XCTAssertEqual(merged["key1"] as? String, "value")
    }
    
    func testDeepMergeDeepNestedArrays() {
        let dict1: [String: Any] = [
            "key1": ["nestedKey1": [["a", "b"], ["c", "d"]]]
        ]
        let dict2: [String: Any] = [
            "key1": ["nestedKey1": [["e", "f"], ["g", "h"]]]
        ]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = [
            "key1": ["nestedKey1": [["a", "b"], ["c", "d"], ["e", "f"], ["g", "h"]]]
        ]
        
        XCTAssertEqual(merged as NSDictionary, expected as NSDictionary)
    }
    
    func testDeepMergeDeepNestedDictionaries() {
        let dict1: [String: Any] = [
            "key1": [
                "nestedKey1": [
                    "deepNestedKey1": "value1"
                ],
                "nestedKey2": [1, 2, 3]
            ]
        ]
        let dict2: [String: Any] = [
            "key1": [
                "nestedKey1": [
                    "deepNestedKey2": "value2"
                ],
                "nestedKey2": [3, 4, 5]
            ]
        ]
        
        let merged = dict1.deepMerging(with: dict2)
        let expected: [String: Any] = [
            "key1": [
                "nestedKey1": [
                    "deepNestedKey1": "value1",
                    "deepNestedKey2": "value2"
                ],
                "nestedKey2": [1, 2, 3, 4, 5]
            ]
        ]
        
        XCTAssertEqual(merged as NSDictionary, expected as NSDictionary)
    }
    
    private func collectionToString(_ dict: [AnyHashable: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        return jsonString
    }
}

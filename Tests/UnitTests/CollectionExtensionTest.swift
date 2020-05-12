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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
        let array: [Signals.SingleContainerInt] = [1, 2, 5]
        
        //when
        let intArray = array.toIntArray()
        
        //then
        XCTAssertEqual(3, intArray.count)
        XCTAssertTrue(intArray.contains(1) && intArray.contains(2) && intArray.contains(5))
    }
    
    private func collectionToString(_ dict: [AnyHashable: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        return jsonString
    }
    
}

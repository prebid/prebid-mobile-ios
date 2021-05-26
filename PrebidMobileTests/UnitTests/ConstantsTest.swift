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

class ConstantsTest: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }
    
    func testSetExtensionToCommaSeparatedListString() {
        var stringSet = Set<String>()
        
        XCTAssert(stringSet.toCommaSeparatedListString().isEmpty)
        
        stringSet.insert("value1")
        
        XCTAssert(stringSet.toCommaSeparatedListString() == "value1")
        
        stringSet.insert("value2")
        
        XCTAssert(stringSet.toCommaSeparatedListString() == "value1,value2" || stringSet.toCommaSeparatedListString() == "value2,value1" )
        
        stringSet.removeAll()
        
        var intSet = Set<Int>()
        
        XCTAssert(intSet.toCommaSeparatedListString().isEmpty)
        
        intSet.insert(1)
        
        XCTAssert(intSet.toCommaSeparatedListString() == "1")
        
        intSet.insert(2)
        
        XCTAssert(intSet.toCommaSeparatedListString() == "1,2" || intSet.toCommaSeparatedListString() == "2,1")
    }

    func testDictionatyExtensionAddValue() {
        var dictionary = [String: Set<String>]()

        //add key1/value10
        dictionary.addValue("value10", forKey: "key1")
        XCTAssert(dictionary.count == 1)
        
        guard let key1Set1 = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key1Set1.count == 1)
        XCTAssert(key1Set1.contains("value10"))
        
         //add key2/value20
        dictionary.addValue("value20", forKey: "key2")
        XCTAssert(dictionary.count == 2)
        
        guard let key2Set1 = dictionary["key2"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key2Set1.count == 1)
        XCTAssert(key2Set1.contains("value20"))
        
        //add key1/value11
        dictionary.addValue("value11", forKey: "key1")
        XCTAssert(dictionary.count == 2)
        
        guard let key1Set2 = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key1Set2.count == 2)
        XCTAssert(key1Set2.contains("value10") && key1Set2.contains("value11"))
        
        //add new values
        dictionary.updateValue(["value30", "value31", "value32"], forKey: "key3")
        XCTAssert(dictionary.count == 3)
        
        guard let key3Set1 = dictionary["key3"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key3Set1.count == 3)
        XCTAssert(key3Set1.contains("value30") && key3Set1.contains("value31") && key3Set1.contains("value32"))
        
        //replace values
        dictionary.updateValue(["value33", "value34", "value35"], forKey: "key3")
        XCTAssert(dictionary.count == 3)
        
        guard let key3Set2 = dictionary["key3"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key3Set2.count == 3)
        XCTAssert(key3Set2.contains("value33") && key3Set2.contains("value34") && key3Set2.contains("value35"))
        
        //add new values
        dictionary.addValue("value36", forKey: "key3")
        dictionary.addValue("value37", forKey: "key3")
        dictionary.addValue("value38", forKey: "key3")
        XCTAssert(dictionary.count == 3)
        
        guard let key3Set3 = dictionary["key3"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key3Set3.count == 6)
        XCTAssert(key3Set3.contains("value33") && key3Set3.contains("value34") && key3Set3.contains("value35") && key3Set3.contains("value36") && key3Set3.contains("value37") && key3Set3.contains("value38"))
        
        dictionary.removeValue(forKey: "key3")
        XCTAssert(dictionary.count == 2)
        
        dictionary.removeAll()
        XCTAssert(dictionary.count == 0)
    }
    
    func testDictionatyExtensionGetCopyWhereValueIsArray() {
        var dictionary = [String: Set<String>]()
        dictionary.addValue("value10", forKey: "key1")
        dictionary.addValue("value20", forKey: "key2")
        dictionary.addValue("value21", forKey: "key2")
        dictionary.updateValue(["value30", "value31", "value32"], forKey: "key3")
        
        let resultDictionary = dictionary.getCopyWhereValueIsArray()
        XCTAssert(resultDictionary.count == 3)
        
        guard let key1Array1 = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }
        
        XCTAssert(key1Array1.contains("value10"))
        
        guard let key2Array1 = dictionary["key2"] else {
            XCTFail("set is nil")
            return
        }
        
        XCTAssert(key2Array1.contains("value20") && key2Array1.contains("value21"))
        
        guard let key3Array1 = dictionary["key3"] else {
            XCTFail("set is nil")
            return
        }
        
        XCTAssert(key3Array1.contains("value30") && key3Array1.contains("value31") && key3Array1.contains("value32"))
    }
    
    func testDictionatyExtensionToCommaSeparatedListString() {
        var dictionary = [String: Set<String>]()
        dictionary.addValue("value10", forKey: "key1")
        dictionary.addValue("value20", forKey: "key2")
        dictionary.addValue("value21", forKey: "key2")
        
        let commaSeparatedList = dictionary.toCommaSeparatedListString()
        
        XCTAssert(
            commaSeparatedList == "key1=value10,key2=value20,key2=value21"
                || commaSeparatedList == "key1=value10,key2=value21,key2=value20"
                || commaSeparatedList == "key2=value20,key2=value21,key1=value10"
                || commaSeparatedList == "key2=value20,key1=value10,key2=value21"
                || commaSeparatedList == "key2=value21,key1=value10,key2=value20"
                || commaSeparatedList == "key2=value21,key2=value20,key1=value10",
            commaSeparatedList)
    }
    
    func testDictionaryExtensionToString() {
        var dictionary = [String: String]()
        dictionary["key1"] = "value1"
        dictionary["key2"] = "value2"
        
        let result = dictionary.toString(entrySeparator: "|", keyValueSeparator: "~")
        
        XCTAssertTrue(
            result == "key1~value1|key2~value2"
                || result == "key2~value2|key1~value1",
            result
        )
        
    }
    
    func testDictionaryExtensionToStringWhereValueIsSet() {
        var dictionary = [String: Set<String>]()
        dictionary.addValue("value10", forKey: "key1")
        dictionary.addValue("value20", forKey: "key2")
        dictionary.addValue("value21", forKey: "key2")
        
        let resultList = dictionary.toString(entrySeparator: "|", keyValueSeparator: "~")
        
        XCTAssert(
            resultList == "key1~value10|key2~value20|key2~value21"
                || resultList == "key1~value10|key2~value21|key2~value20"
                || resultList == "key2~value20|key2~value21|key1~value10"
                || resultList == "key2~value20|key1~value10|key2~value21"
                || resultList == "key2~value21|key1~value10|key2~value20"
                || resultList == "key2~value21|key2~value20|key1~value10",
            resultList)
    }

}

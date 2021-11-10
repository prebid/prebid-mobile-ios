/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

class TestStringExtension: XCTestCase {
    
    let animalString = "catcatdogmouse"
    
    func testNumberOfMatches() {
        
        //Simple tests
        var result = animalString.PBMnumberOfMatches("cat")
        XCTAssert(result == 2, "Expected 2 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("dog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("mouse")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("zebra")
        XCTAssert(result == 0, "Expected 0 matches, got \(result)")
        
        result = animalString.PBMnumberOfMatches("catcatdog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("catcatdogmouse")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        //Regex Tests
        result = animalString.PBMnumberOfMatches("cat.+dog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("mouse.+cat")
        XCTAssert(result == 0, "Expected 0 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("^cat")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("mouse$")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("[0-9]")
        XCTAssert(result == 0, "Expected 0 match, got \(result)")
        
        result = animalString.PBMnumberOfMatches("[a-z]")
        XCTAssert(result == animalString.count, "Expected \(animalString.count), got \(result)")
        
        result = animalString.PBMnumberOfMatches("c.tc.td.gm.us.")
        XCTAssert(result == 1, "Expected 1, got \(result)")
        
        result = animalString.PBMnumberOfMatches("cat\\.")
        XCTAssert(result == 0, "Expected 0, got \(result)")
    }
    
    func testDoesMatch() {
        XCTAssert(animalString.PBMdoesMatch("cat"), "Unexpected doesMatch Result")
        XCTAssert(!animalString.PBMdoesMatch("zebra"), "Unexpected doesMatch Result")
        XCTAssert(animalString.PBMdoesMatch("[a-z]"), "Unexpected doesMatch Result")
        XCTAssert(animalString.PBMdoesMatch("c.tc.td.gm.us."), "Unexpected doesMatch Result")
        XCTAssert(!animalString.PBMdoesMatch("cat\\."), "Unexpected doesMatch Result")
        
        //Negative lookahead
        XCTAssert(animalString.PBMdoesMatch("^((?!dog).)*dog.+"), "Unexpected doesMatch Result")
    }
    
    func testSubstringFromString() {
        
        //Standard
        var actual:String? = "foobarbaz".PBMsubstringFromString("foo")
        var expected:String? = "barbaz"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //End
        actual = "foobarbaz".PBMsubstringFromString("baz")
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //same
        actual = "foobarbaz".PBMsubstringFromString("foobarbaz")
        expected = "";
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //EmptyString
        actual = "foobarbaz".PBMsubstringFromString("")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //not found
        actual = "foobarbaz".PBMsubstringFromString("NotFound")
        expected = nil;
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
    func testSubstringToString() {
        
        //Standard
        var actual:String? = "foobarbaz".PBMsubstringToString("bar")
        var expected:String? = "foo"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Start of String
        actual = "foobarbaz".PBMsubstringToString("foo")
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //EmptyString
        actual = "foobarbaz".PBMsubstringToString("")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //not found
        actual = "foobarbaz".PBMsubstringToString("NotFound")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
    
    func testSubstringFromStringToString() {
        
        //Standard
        var actual:String? = "foobarbaz".PBMsubstringFromString("foo", toString:"baz")
        var expected:String? = "bar"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //End before beginning
        actual = "foobarbaz".PBMsubstringFromString("baz", toString:"foo")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Empty String inputs
        actual = "foobarbaz".PBMsubstringFromString("", toString:"baz")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromString("foo", toString:"")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromString("", toString:"")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        
        actual = "<NSThread: 0x7f806ffce890>{number = 4, name = (null)}".PBMsubstringFromString("number = ", toString:",")
        expected = "4"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
    
    func testPBMstringByReplacingRegex() {
        
        //Simple example (doesn't really use regex)
        var actual = "foobarbaz".PBMstringByReplacingRegex("bar", replaceWith:"baz")
        var expected = "foobazbaz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Simple .+ examples
        actual = "foobarbaz".PBMstringByReplacingRegex("f.+", replaceWith:"baz")
        expected = "baz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        actual = "foo\"bar\"baz".PBMstringByReplacingRegex("\".+\"", replaceWith:"\"baz\"")
        expected = "foo\"baz\"baz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Group, trivial example (replace with self)
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".PBMstringByReplacingRegex("\"(.+)\"", replaceWith:"\"$1\"")
        expected = "a href=\"foo.com?key1=val1&key2=val2\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Group, append stuff
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".PBMstringByReplacingRegex("\"(.+)\"", replaceWith:"\"$1&key3=val3\"")
        expected = "a href=\"foo.com?key1=val1&key2=val2&key3=val3\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Regex "Not"
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".PBMstringByReplacingRegex("foo.com\\?[^'\"]+", replaceWith:"foo.com?bar=baz")
        expected = "a href=\"foo.com?bar=baz\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Regex "Not" With Group & Append
        actual = "a href=\"foo.com\(PBMTrackingPattern.RI.rawValue)?key1=val1&key2=val2\"".PBMstringByReplacingRegex("\(PBMTrackingPattern.RI.rawValue)\\?([^'\"]+)", replaceWith:"\(PBMTrackingPattern.RI.rawValue)?$1&bar=baz")
        expected = "a href=\"foo.com\(PBMTrackingPattern.RI.rawValue)?key1=val1&key2=val2&bar=baz\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
    }
    
    func testPBMsubstringFromIndex() {
        
        //Basic test
        var actual:String? = "foobarbaz".PBMsubstringFromIndex(0, toIndex:3)
        var expected:String? = "foo"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Error handling
        actual = "foobarbaz".PBMsubstringFromIndex(0, toIndex:-1)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(-1, toIndex:0)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(3, toIndex:0)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //More complicated regular tests
        actual = "foobarbaz".PBMsubstringFromIndex(0, toIndex:0)
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(3, toIndex:6)
        expected = "bar"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(0, toIndex:1)
        expected = "f"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(0, toIndex:9)
        expected = "foobarbaz"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(8, toIndex:9)
        expected = "z"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".PBMsubstringFromIndex(1, toIndex:10)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
}

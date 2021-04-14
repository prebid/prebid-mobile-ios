
import XCTest
@testable import PrebidMobileRendering

class TestStringExtension: XCTestCase {

    let animalString = "catcatdogmouse"
    
    func testNumberOfMatches() {

        //Simple tests
        var result = animalString.OXMnumberOfMatches("cat")
        XCTAssert(result == 2, "Expected 2 match, got \(result)")

        result = animalString.OXMnumberOfMatches("dog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")

        result = animalString.OXMnumberOfMatches("mouse")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.OXMnumberOfMatches("zebra")
        XCTAssert(result == 0, "Expected 0 matches, got \(result)")
        
        result = animalString.OXMnumberOfMatches("catcatdog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.OXMnumberOfMatches("catcatdogmouse")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        //Regex Tests
        result = animalString.OXMnumberOfMatches("cat.+dog")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")

        result = animalString.OXMnumberOfMatches("mouse.+cat")
        XCTAssert(result == 0, "Expected 0 match, got \(result)")
        
        result = animalString.OXMnumberOfMatches("^cat")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")

        result = animalString.OXMnumberOfMatches("mouse$")
        XCTAssert(result == 1, "Expected 1 match, got \(result)")
        
        result = animalString.OXMnumberOfMatches("[0-9]")
        XCTAssert(result == 0, "Expected 0 match, got \(result)")

        result = animalString.OXMnumberOfMatches("[a-z]")
        XCTAssert(result == animalString.count, "Expected \(animalString.count), got \(result)")
        
        result = animalString.OXMnumberOfMatches("c.tc.td.gm.us.")
        XCTAssert(result == 1, "Expected 1, got \(result)")

        result = animalString.OXMnumberOfMatches("cat\\.")
        XCTAssert(result == 0, "Expected 0, got \(result)")
    }

    func testDoesMatch() {
        XCTAssert(animalString.OXMdoesMatch("cat"), "Unexpected doesMatch Result")
        XCTAssert(!animalString.OXMdoesMatch("zebra"), "Unexpected doesMatch Result")
        XCTAssert(animalString.OXMdoesMatch("[a-z]"), "Unexpected doesMatch Result")
        XCTAssert(animalString.OXMdoesMatch("c.tc.td.gm.us."), "Unexpected doesMatch Result")
        XCTAssert(!animalString.OXMdoesMatch("cat\\."), "Unexpected doesMatch Result")
		
		//Negative lookahead
        XCTAssert(animalString.OXMdoesMatch("^((?!dog).)*dog.+"), "Unexpected doesMatch Result")
    }

    func testSubstringFromString() {
        
        //Standard
        var actual:String? = "foobarbaz".OXMsubstringFromString("foo")
        var expected:String? = "barbaz"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //End
        actual = "foobarbaz".OXMsubstringFromString("baz")
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")

        //same
        actual = "foobarbaz".OXMsubstringFromString("foobarbaz")
        expected = "";
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //EmptyString
        actual = "foobarbaz".OXMsubstringFromString("")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //not found
        actual = "foobarbaz".OXMsubstringFromString("NotFound")
        expected = nil;
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
    func testSubstringToString() {
        
        //Standard
        var actual:String? = "foobarbaz".OXMsubstringToString("bar")
        var expected:String? = "foo"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Start of String
        actual = "foobarbaz".OXMsubstringToString("foo")
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //EmptyString
        actual = "foobarbaz".OXMsubstringToString("")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //not found
        actual = "foobarbaz".OXMsubstringToString("NotFound")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
    
    func testSubstringFromStringToString() {
        
        //Standard
        var actual:String? = "foobarbaz".OXMsubstringFromString("foo", toString:"baz")
        var expected:String? = "bar"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //End before beginning
        actual = "foobarbaz".OXMsubstringFromString("baz", toString:"foo")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Empty String inputs
        actual = "foobarbaz".OXMsubstringFromString("", toString:"baz")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromString("foo", toString:"")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")

        actual = "foobarbaz".OXMsubstringFromString("", toString:"")
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
    
        actual = "<NSThread: 0x7f806ffce890>{number = 4, name = (null)}".OXMsubstringFromString("number = ", toString:",")
        expected = "4"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }

    
    func testOXMstringByReplacingRegex() {
        
        //Simple example (doesn't really use regex)
        var actual = "foobarbaz".OXMstringByReplacingRegex("bar", replaceWith:"baz")
        var expected = "foobazbaz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Simple .+ examples
        actual = "foobarbaz".OXMstringByReplacingRegex("f.+", replaceWith:"baz")
        expected = "baz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")

        actual = "foo\"bar\"baz".OXMstringByReplacingRegex("\".+\"", replaceWith:"\"baz\"")
        expected = "foo\"baz\"baz"
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Group, trivial example (replace with self)
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".OXMstringByReplacingRegex("\"(.+)\"", replaceWith:"\"$1\"")
        expected = "a href=\"foo.com?key1=val1&key2=val2\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Group, append stuff
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".OXMstringByReplacingRegex("\"(.+)\"", replaceWith:"\"$1&key3=val3\"")
        expected = "a href=\"foo.com?key1=val1&key2=val2&key3=val3\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
        
        //Regex "Not"
        actual = "a href=\"foo.com?key1=val1&key2=val2\"".OXMstringByReplacingRegex("foo.com\\?[^'\"]+", replaceWith:"foo.com?bar=baz")
        expected = "a href=\"foo.com?bar=baz\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")

        //Regex "Not" With Group & Append
        actual = "a href=\"foo.com\(OXMTrackingPattern.RI.rawValue)?key1=val1&key2=val2\"".OXMstringByReplacingRegex("\(OXMTrackingPattern.RI.rawValue)\\?([^'\"]+)", replaceWith:"\(OXMTrackingPattern.RI.rawValue)?$1&bar=baz")
        expected = "a href=\"foo.com\(OXMTrackingPattern.RI.rawValue)?key1=val1&key2=val2&bar=baz\""
        XCTAssert(expected == actual, "expected \(expected), got \(actual)")
    }
    
    func testOXMsubstringFromIndex() {

        //Basic test
        var actual:String? = "foobarbaz".OXMsubstringFromIndex(0, toIndex:3)
        var expected:String? = "foo"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //Error handling
        actual = "foobarbaz".OXMsubstringFromIndex(0, toIndex:-1)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")

        actual = "foobarbaz".OXMsubstringFromIndex(-1, toIndex:0)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromIndex(3, toIndex:0)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        //More complicated regular tests
        actual = "foobarbaz".OXMsubstringFromIndex(0, toIndex:0)
        expected = ""
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromIndex(3, toIndex:6)
        expected = "bar"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromIndex(0, toIndex:1)
        expected = "f"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromIndex(0, toIndex:9)
        expected = "foobarbaz"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
        
        actual = "foobarbaz".OXMsubstringFromIndex(8, toIndex:9)
        expected = "z"
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")

        actual = "foobarbaz".OXMsubstringFromIndex(1, toIndex:10)
        expected = nil
        XCTAssert(expected == actual, "expected \(String(describing: expected)), got \(String(describing: actual))")
    }
    
}

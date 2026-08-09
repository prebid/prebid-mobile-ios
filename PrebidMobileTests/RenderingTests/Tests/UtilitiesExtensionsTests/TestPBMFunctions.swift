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

import UIKit
import XCTest
@_spi(PBMInternal) @testable import PrebidMobile

class TestFunctions: XCTestCase {
    
    // Source: https://github.com/semver/semver/issues/232
    let versionValidatorRegExpr = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(-(0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(\\.(0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\\+[0-9a-zA-Z-]+(\\.[0-9a-zA-Z-]+)*)?$"

    func testAttemptToOpenURL() {
        
        let url = URL(string:"foo://bar")!
        let mockUIApplication = MockUIApplication()
        
        let expectation = self.expectation(description: "expected MockUIApplication.openURL to fire")
        mockUIApplication.openURLClosure = { _ in
            expectation.fulfill()
            return true
        }
        
        Functions.attemptToOpen(url, pbmUIApplication: mockUIApplication)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    
    func testClampInt() {
        
        var expected:Int
        var actual:Int
        
        //Simple
        expected = 5
        actual = Functions.clampInt(5, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = 1
        actual = Functions.clampInt(0, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = 10
        actual = Functions.clampInt(1000, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)

        //Equal to upperBound
        expected = 10
        actual = Functions.clampInt(10, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = 1
        actual = Functions.clampInt(1, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //////////////////
        //Negative Numbers
        //////////////////
        
        //Simple
        expected = -5
        actual = Functions.clampInt(-5, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = -10
        actual = Functions.clampInt(-1000, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)

        //Higher than upperBound
        expected = -1
        actual = Functions.clampInt(1000, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = -10
        actual = Functions.clampInt(-10, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)

        //Equal to upperBound
        expected = -1
        actual = Functions.clampInt(-1, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
    }
    
    func testClampDouble() {
        
        var expected:Double
        var actual:Double
        
        //Simple
        expected = 5.1
        actual = Functions.clamp(5.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = 1.1
        actual = Functions.clamp(0.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = 10.1
        actual = Functions.clamp(1000.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Equal to upperBound
        expected = 10.1
        actual = Functions.clamp(10.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = 1.1
        actual = Functions.clamp(1.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //////////////////
        //Negative Numbers
        //////////////////
        
        //Simple
        expected = -5.1
        actual = Functions.clamp(-5.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = -10.1
        actual = Functions.clamp(-1000.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = -1.1
        actual = Functions.clamp(1000.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = -10.1
        actual = Functions.clamp(-10.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Equal to upperBound
        expected = -1.1
        actual = Functions.clamp(-1.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
    }
    
    
    func testDictionaryFromDataWithEmptyData() {

        do {
            try _ = Functions.dictionaryFromData(Data())
        } catch {
            return
        }
        
        XCTFail("Expected an error ")
    }
    
    func testDictionaryFromDataWithLocalData() {
        
        let files = ["ACJBanner.json", "ACJSingleAdWithoutSDKParams.json"]
        
        for file in files {
            
            guard let data = UtilitiesForTesting.loadFileAsDataFromBundle(file) else {
                XCTFail("could not load \(file)")
                continue
            }

            guard let jsonDict = try? Functions.dictionaryFromData(data) else {
                XCTFail()
                return
            }
            
            XCTAssert(jsonDict.keys.count > 0)
        }
    }
    
    func testDictionaryFromJSONString() {
        let jsonString = UtilitiesForTesting.loadFileAsStringFromBundle("ACJBanner.json")!
        
        guard let dict = try? Functions.dictionaryFromJSONString(jsonString) else {
            XCTFail()
            return
        }
        
        guard let ads = dict["ads"] as? JsonDictionary else {
            XCTFail()
            return
        }

        guard let adunits = ads["adunits"] as? [JsonDictionary] else {
            XCTFail()
            return
        }
        
        guard let firstAdUnit = adunits.first else {
            XCTFail()
            return
        }
        
        guard let auid = firstAdUnit["auid"] as? String else {
            XCTFail()
            return
        }
        
        XCTAssert(auid == "1610810552")
    }

    func testInfoPlistValue() {
        
        //Basic tests
        var result = Functions.infoPlistValue("CFBundleExecutable")
        XCTAssert(result?.PBMdoesMatch("PrebidMobile") == true, "Got \(String(describing: result))")
        
        result = Functions.infoPlistValue("CFBundleIdentifier")
        XCTAssert(result?.PBMdoesMatch("org.prebid.mobile") == true, "Got \(String(describing: result))")
        
        //Version number should start and end with an unbroken string of numbers or periods.
        result = Functions.infoPlistValue("CFBundleShortVersionString")
        XCTAssert(result?.PBMdoesMatch(versionValidatorRegExpr) == true, "Got \(String(describing: result))")
        
        //Expected failures
        result = Functions.infoPlistValue("DERP")
        XCTAssert(result?.PBMdoesMatch("^[0-9\\.]+$") == nil, "Got \(String(describing: result))")
        
        result = Functions.infoPlistValue("aklhakfhadlskfhlkahf")
        XCTAssert(result == nil, "Got \(String(describing: result))")
    }
    
    func testsdkVersion() {
        let version = PrebidConstants.PREBID_VERSION
        XCTAssert(version.count > 0)
        XCTAssert(version.PBMdoesMatch(versionValidatorRegExpr) == true, "Got \(String(describing: version))")
    }
    
    func testStatusBarHeight() {
        
        let mockApplication = MockUIApplication()

        //Test with default (visible status bar in portrait)
        var expected:CGFloat = 2.0
        var actual = Functions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
        
        //Test with visible status bar in landscape
        mockApplication.statusBarOrientation = .landscapeLeft
        expected = 1.0
        actual = Functions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")

        //Test with hidden status bar
        mockApplication.isStatusBarHidden = true
        expected = 0.0
        actual = Functions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
    }
    
    // MARK: JSON
    
    func testDictionaryFromDataWithInvalidData() {
        
        let data = UtilitiesForTesting.loadFileAsDataFromBundle("mraid.js")!

        var dict: JsonDictionary?
        do {
            dict = try Functions.dictionaryFromData(data)
            XCTFail("Test method should throw exception")
        }
        catch {
            // The ObjC original wrapped the parse failure in its own PBMError
            // ("Could not convert json data to jsonObject:"); the Swift port lets
            // JSONSerialization's error propagate unwrapped. Assert on domain/code rather
            // than the message, which is localized.
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nsError.code, 3840) // JSON parse failure
        }
        
        XCTAssertNil(dict)
    }
    
    func testDictionaryFromDataWithInvalidJSON() {
        
        let data = "[\"A\", \"B\", \"C\"]".data(using: .utf8)!

        var dict: JsonDictionary?
        do {
            dict = try Functions.dictionaryFromData(data)
            XCTFail("Test method should throw exception")
        }
        catch {
            // Well-formed JSON whose top-level element is an array. ObjC said
            // "Could not cast jsonObject to JsonDictionary:"; the Swift port reworded it.
            XCTAssertTrue(error.localizedDescription.contains("Invalid JSON data"),
                          "unexpected error: \(error.localizedDescription)")
        }
        
        XCTAssertNil(dict)
    }
    
    func testDictionaryFromData() {
        
        let data = "{\"key\" : \"value\"}".data(using: .utf8)!
        
        let dict = try! Functions.dictionaryFromData(data)
        
        XCTAssertEqual(dict["key"] as! String, "value")
    }
    
    func testToStringJsonDictionaryWithInvalidJSON() {
        let jsonDict: JsonDictionary = ["test" : UIImage()]
        
        var jsonString: String?
        do {
            jsonString = try Functions.toStringJsonDictionary(jsonDict)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Not valid JSON object:"))
        }
        
        XCTAssertNil(jsonString)
    }
    
    func testExtractVideoAdParamsFromTheURLString() {
        let urlCorrectString = "http://mobile-d.openx.net/v/1.0/av?auid=540851203"
        let resultDict = Functions.extractVideoAdParams(fromURLString: urlCorrectString, forKeys: ["auid"])
        XCTAssertEqual(resultDict["domain"], "mobile-d.openx.net")
        XCTAssertEqual(resultDict["auid"], "540851203")
        
        let urlIncorrectString = "http./mobile-d.openx.net.auid.540851203"
        let resultDict2 = Functions.extractVideoAdParams(fromURLString: urlIncorrectString, forKeys: ["auid"])
        XCTAssertNil(resultDict2["domain"])
        XCTAssertNil(resultDict2["auid"])
    }
}

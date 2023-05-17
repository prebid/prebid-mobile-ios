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
@testable import PrebidMobile

class TestPBMFunctions: XCTestCase {
    
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
        
        PBMFunctions.attempt(toOpen:url, pbmUIApplication:mockUIApplication)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    
    func testClampInt() {
        
        var expected:Int
        var actual:Int
        
        //Simple
        expected = 5
        actual = PBMFunctions.clampInt(5, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = 1
        actual = PBMFunctions.clampInt(0, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = 10
        actual = PBMFunctions.clampInt(1000, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)

        //Equal to upperBound
        expected = 10
        actual = PBMFunctions.clampInt(10, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = 1
        actual = PBMFunctions.clampInt(1, lowerBound:1, upperBound:10)
        XCTAssert(expected == actual)
        
        //////////////////
        //Negative Numbers
        //////////////////
        
        //Simple
        expected = -5
        actual = PBMFunctions.clampInt(-5, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = -10
        actual = PBMFunctions.clampInt(-1000, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)

        //Higher than upperBound
        expected = -1
        actual = PBMFunctions.clampInt(1000, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = -10
        actual = PBMFunctions.clampInt(-10, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)

        //Equal to upperBound
        expected = -1
        actual = PBMFunctions.clampInt(-1, lowerBound:-10, upperBound:-1)
        XCTAssert(expected == actual)
    }
    
    func testClampDouble() {
        
        var expected:Double
        var actual:Double
        
        //Simple
        expected = 5.1
        actual = PBMFunctions.clamp(5.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = 1.1
        actual = PBMFunctions.clamp(0.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = 10.1
        actual = PBMFunctions.clamp(1000.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Equal to upperBound
        expected = 10.1
        actual = PBMFunctions.clamp(10.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = 1.1
        actual = PBMFunctions.clamp(1.1, lowerBound:1.1, upperBound:10.1)
        XCTAssert(expected == actual)
        
        //////////////////
        //Negative Numbers
        //////////////////
        
        //Simple
        expected = -5.1
        actual = PBMFunctions.clamp(-5.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Lower than lowBound
        expected = -10.1
        actual = PBMFunctions.clamp(-1000.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Higher than upperBound
        expected = -1.1
        actual = PBMFunctions.clamp(1000.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Equal to lowerBound
        expected = -10.1
        actual = PBMFunctions.clamp(-10.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
        
        //Equal to upperBound
        expected = -1.1
        actual = PBMFunctions.clamp(-1.1, lowerBound:-10.1, upperBound:-1.1)
        XCTAssert(expected == actual)
    }
    
    
    func testDictionaryFromDataWithEmptyData() {

        do {
            try _ = PBMFunctions.dictionaryFromData(Data())
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

            guard let jsonDict = try? PBMFunctions.dictionaryFromData(data) else {
                XCTFail()
                return
            }
            
            XCTAssert(jsonDict.keys.count > 0)
        }
    }
    
    func testDictionaryFromJSONString() {
        let jsonString = UtilitiesForTesting.loadFileAsStringFromBundle("ACJBanner.json")!
        
        guard let dict = try? PBMFunctions.dictionaryFromJSONString(jsonString) else {
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
        var result = PBMFunctions.infoPlistValue("CFBundleExecutable")
        XCTAssert(result?.PBMdoesMatch("PrebidMobile") == true, "Got \(String(describing: result))")
        
        result = PBMFunctions.infoPlistValue("CFBundleIdentifier")
        XCTAssert(result?.PBMdoesMatch("org.prebid.mobile") == true, "Got \(String(describing: result))")
        
        //Version number should start and end with an unbroken string of numbers or periods.
        result = PBMFunctions.infoPlistValue("CFBundleShortVersionString")
        XCTAssert(result?.PBMdoesMatch(versionValidatorRegExpr) == true, "Got \(String(describing: result))")
        
        //Expected failures
        result = PBMFunctions.infoPlistValue("DERP")
        XCTAssert(result?.PBMdoesMatch("^[0-9\\.]+$") == nil, "Got \(String(describing: result))")
        
        result = PBMFunctions.infoPlistValue("aklhakfhadlskfhlkahf")
        XCTAssert(result == nil, "Got \(String(describing: result))")
    }
    
    func testsdkVersion() {
        let version = PBMFunctions.sdkVersion()
        XCTAssert(version.count > 0)
        XCTAssert(version.PBMdoesMatch(versionValidatorRegExpr) == true, "Got \(String(describing: version))")
    }
    
    func testStatusBarHeight() {
        
        let mockApplication = MockUIApplication()

        //Test with default (visible status bar in portrait)
        var expected:CGFloat = 2.0
        var actual = PBMFunctions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
        
        //Test with visible status bar in landscape
        mockApplication.statusBarOrientation = .landscapeLeft
        expected = 1.0
        actual = PBMFunctions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")

        //Test with hidden status bar
        mockApplication.isStatusBarHidden = true
        expected = 0.0
        actual = PBMFunctions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
    }
    
    // MARK: JSON
    
    func testDictionaryFromDataWithInvalidData() {
        
        let data = UtilitiesForTesting.loadFileAsDataFromBundle("mraid.js")!
    
        var dict: JsonDictionary?
        do {
            dict = try PBMFunctions.dictionaryFromData(data)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Could not convert json data to jsonObject:"))
        }
        
        XCTAssertNil(dict)
    }
    
    func testDictionaryFromDataWithInvalidJSON() {
        
        let data = "[\"A\", \"B\", \"C\"]".data(using: .utf8)!
        
        var dict: JsonDictionary?
        do {
            dict = try PBMFunctions.dictionaryFromData(data)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Could not cast jsonObject to JsonDictionary:"))
        }
        
        XCTAssertNil(dict)
    }
    
    func testDictionaryFromData() {
        
        let data = "{\"key\" : \"value\"}".data(using: .utf8)!
        
        let dict = try! PBMFunctions.dictionaryFromData(data)
        
        XCTAssertEqual(dict["key"] as! String, "value")
    }
    
    func testToStringJsonDictionaryWithInvalidJSON() {
        let jsonDict: JsonDictionary = ["test" : UIImage()]
        
        var jsonString: String?
        do {
            jsonString = try PBMFunctions.toStringJsonDictionary(jsonDict)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Not valid JSON object:"))
        }
        
        XCTAssertNil(jsonString)
    }
    
    func testExtractVideoAdParamsFromTheURLString() {
        let urlCorrectString = "http://mobile-d.openx.net/v/1.0/av?auid=540851203"
        let resultDict = PBMFunctions.extractVideoAdParams(fromTheURLString: urlCorrectString, forKeys: ["auid"])
        XCTAssertEqual(resultDict["domain"], "mobile-d.openx.net")
        XCTAssertEqual(resultDict["auid"], "540851203")
        
        let urlIncorrectString = "http./mobile-d.openx.net.auid.540851203"
        let resultDict2 = PBMFunctions.extractVideoAdParams(fromTheURLString: urlIncorrectString, forKeys: ["auid"])
        XCTAssertNil(resultDict2["domain"])
        XCTAssertNil(resultDict2["auid"])
    }
}

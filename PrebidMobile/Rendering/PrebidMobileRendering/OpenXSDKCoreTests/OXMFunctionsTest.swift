//
//  OXMFuntionsTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//
import UIKit
import XCTest
@testable import PrebidMobileRendering

class TestOXMFunctions: XCTestCase {

    func testAttemptToOpenURL() {
        
        let url = URL(string:"foo://bar")!
        let mockUIApplication = MockUIApplication()
        
        let expectation = self.expectation(description: "expected MockUIApplication.openURL to fire")
        mockUIApplication.openURLClosure = { _ in
            expectation.fulfill()
            return true
        }
        
        OXMFunctions.attempt(toOpen:url, oxmUIApplication:mockUIApplication)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    
	func testClampInt() {
		
		var expected:Int
		var actual:Int
		
		//Simple
		expected = 5
		actual = OXMFunctions.clampInt(5, lowerBound:1, upperBound:10)
		XCTAssert(expected == actual)
		
		//Lower than lowBound
		expected = 1
		actual = OXMFunctions.clampInt(0, lowerBound:1, upperBound:10)
		XCTAssert(expected == actual)
		
		//Higher than upperBound
		expected = 10
		actual = OXMFunctions.clampInt(1000, lowerBound:1, upperBound:10)
		XCTAssert(expected == actual)

		//Equal to upperBound
		expected = 10
		actual = OXMFunctions.clampInt(10, lowerBound:1, upperBound:10)
		XCTAssert(expected == actual)
		
		//Equal to lowerBound
		expected = 1
		actual = OXMFunctions.clampInt(1, lowerBound:1, upperBound:10)
		XCTAssert(expected == actual)
		
		//////////////////
		//Negative Numbers
		//////////////////
		
		//Simple
		expected = -5
		actual = OXMFunctions.clampInt(-5, lowerBound:-10, upperBound:-1)
		XCTAssert(expected == actual)
		
		//Lower than lowBound
		expected = -10
		actual = OXMFunctions.clampInt(-1000, lowerBound:-10, upperBound:-1)
		XCTAssert(expected == actual)

		//Higher than upperBound
		expected = -1
		actual = OXMFunctions.clampInt(1000, lowerBound:-10, upperBound:-1)
		XCTAssert(expected == actual)
		
		//Equal to lowerBound
		expected = -10
		actual = OXMFunctions.clampInt(-10, lowerBound:-10, upperBound:-1)
		XCTAssert(expected == actual)

		//Equal to upperBound
		expected = -1
		actual = OXMFunctions.clampInt(-1, lowerBound:-10, upperBound:-1)
		XCTAssert(expected == actual)
	}
	
	func testClampDouble() {
		
		var expected:Double
		var actual:Double
		
		//Simple
		expected = 5.1
		actual = OXMFunctions.clamp(5.1, lowerBound:1.1, upperBound:10.1)
		XCTAssert(expected == actual)
		
		//Lower than lowBound
		expected = 1.1
		actual = OXMFunctions.clamp(0.1, lowerBound:1.1, upperBound:10.1)
		XCTAssert(expected == actual)
		
		//Higher than upperBound
		expected = 10.1
		actual = OXMFunctions.clamp(1000.1, lowerBound:1.1, upperBound:10.1)
		XCTAssert(expected == actual)
		
		//Equal to upperBound
		expected = 10.1
		actual = OXMFunctions.clamp(10.1, lowerBound:1.1, upperBound:10.1)
		XCTAssert(expected == actual)
		
		//Equal to lowerBound
		expected = 1.1
		actual = OXMFunctions.clamp(1.1, lowerBound:1.1, upperBound:10.1)
		XCTAssert(expected == actual)
		
		//////////////////
		//Negative Numbers
		//////////////////
		
		//Simple
		expected = -5.1
		actual = OXMFunctions.clamp(-5.1, lowerBound:-10.1, upperBound:-1.1)
		XCTAssert(expected == actual)
		
		//Lower than lowBound
		expected = -10.1
		actual = OXMFunctions.clamp(-1000.1, lowerBound:-10.1, upperBound:-1.1)
		XCTAssert(expected == actual)
		
		//Higher than upperBound
		expected = -1.1
		actual = OXMFunctions.clamp(1000.1, lowerBound:-10.1, upperBound:-1.1)
		XCTAssert(expected == actual)
		
		//Equal to lowerBound
		expected = -10.1
		actual = OXMFunctions.clamp(-10.1, lowerBound:-10.1, upperBound:-1.1)
		XCTAssert(expected == actual)
		
		//Equal to upperBound
		expected = -1.1
		actual = OXMFunctions.clamp(-1.1, lowerBound:-10.1, upperBound:-1.1)
		XCTAssert(expected == actual)
	}
	
    
    func testDictionaryFromDataWithEmptyData() {

        do {
            try _ = OXMFunctions.dictionaryFromData(Data())
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

            guard let jsonDict = try? OXMFunctions.dictionaryFromData(data) else {
                XCTFail()
                return
            }
            
            XCTAssert(jsonDict.keys.count > 0)
        }
    }
    
    func testDictionaryFromJSONString() {
        let jsonString = UtilitiesForTesting.loadFileAsStringFromBundle("ACJBanner.json")!
        
        guard let dict = try? OXMFunctions.dictionaryFromJSONString(jsonString) else {
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

	// iOS info
	func testBundleForSDK() {

		let sdkBundle = OXMFunctions.bundleForSDK()
    
		let path = sdkBundle.bundlePath
		
		do {
			
			let fileArray = try FileManager.default.contentsOfDirectory(atPath: path)
			
			for file in fileArray {
				OXMLog.info("file = \(file)")
			}

			//We expect that if this is the SDK Bundle, it will contain a few files
			XCTAssert(fileArray.contains("mraid.js"))
		} catch {
			XCTFail("error = \(error)")
		}
		
	}

    func testInfoPlistValue() {
        
        //Basic tests
        var result = OXMFunctions.infoPlistValue("CFBundleExecutable")
        XCTAssert(result?.OXMdoesMatch("PrebidMobileRendering") == true, "Got \(String(describing: result))")
        
        result = OXMFunctions.infoPlistValue("CFBundleIdentifier")
        XCTAssert(result?.OXMdoesMatch("org.prebid.mobile.rendering") == true, "Got \(String(describing: result))")
        
        //Version number should start and end with an unbroken string of numbers or periods.
        result = OXMFunctions.infoPlistValue("CFBundleShortVersionString")
        XCTAssert(result?.OXMdoesMatch("^[a-z0-9\\.]+$") == true, "Got \(String(describing: result))")
        
        //Expected failures
        result = OXMFunctions.infoPlistValue("DERP")
        XCTAssert(result?.OXMdoesMatch("^[0-9\\.]+$") == nil, "Got \(String(describing: result))")
        
        result = OXMFunctions.infoPlistValue("aklhakfhadlskfhlkahf")
        XCTAssert(result == nil, "Got \(String(describing: result))")
    }
	
    func testsdkVersion() {
        let version = OXMFunctions.sdkVersion()
        XCTAssert(version.count > 0)
        XCTAssert(version.OXMdoesMatch("^[a-z0-9\\.]+$") == true, "Got \(String(describing: version))")
    }
    
	func testStatusBarHeight() {
        
        let mockApplication = MockUIApplication()

        //Test with default (visible status bar in portrait)
        var expected:CGFloat = 2.0
        var actual = OXMFunctions.statusBarHeight(application:mockApplication)
		XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
        
        //Test with visible status bar in landscape
        mockApplication.statusBarOrientation = .landscapeLeft
        expected = 1.0
        actual = OXMFunctions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")

        //Test with hidden status bar
        mockApplication.isStatusBarHidden = true
        expected = 0.0
        actual = OXMFunctions.statusBarHeight(application:mockApplication)
        XCTAssert(expected == actual, "Expected \(expected), got \(actual)")
	}
    
    // MARK: JSON
    
    func testDictionaryFromDataWithInvalidData() {
        
        let data = UtilitiesForTesting.loadFileAsDataFromBundle("mraid.js")!
    
        var dict: JsonDictionary?
        do {
            dict = try OXMFunctions.dictionaryFromData(data)
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
            dict = try OXMFunctions.dictionaryFromData(data)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Could not cast jsonObject to JsonDictionary:"))
        }
        
        XCTAssertNil(dict)
    }
    
    func testDictionaryFromData() {
        
        let data = "{\"key\" : \"value\"}".data(using: .utf8)!
        
        let dict = try! OXMFunctions.dictionaryFromData(data)
        
        XCTAssertEqual(dict["key"] as! String, "value")
    }
    
    func testToStringJsonDictionaryWithInvalidJSON() {
        let jsonDict: JsonDictionary = ["test" : UIImage()]
        
        var jsonString: String?
        do {
            jsonString = try OXMFunctions.toStringJsonDictionary(jsonDict)
            XCTFail("Test method should throw exception")
        }
        catch {
            XCTAssert(error.localizedDescription.contains("Not valid JSON object:"))
        }
        
        XCTAssertNil(jsonString)
    }
    
    func testExtractVideoAdParamsFromTheURLString() {
        let urlCorrectString = "http://mobile-d.openx.net/v/1.0/av?auid=540851203"
        let resultDict = OXMFunctions.extractVideoAdParams(fromTheURLString: urlCorrectString, forKeys: ["auid"])
        XCTAssertEqual(resultDict["domain"], "mobile-d.openx.net")
        XCTAssertEqual(resultDict["auid"], "540851203")
        
        let urlIncorrectString = "http./mobile-d.openx.net.auid.540851203"
        let resultDict2 = OXMFunctions.extractVideoAdParams(fromTheURLString: urlIncorrectString, forKeys: ["auid"])
        XCTAssertNil(resultDict2["domain"])
        XCTAssertNil(resultDict2["auid"])
    }
}

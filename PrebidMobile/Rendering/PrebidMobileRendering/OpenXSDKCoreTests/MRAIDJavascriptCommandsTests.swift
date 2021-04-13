//
//  MRAIDJavascriptCommandsTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

// This test case was created during porting SDK to Objective-C.
// The purpose of these tests is to be sure that methods' parameters are converted to the output strings properly.
// Just in case tests for string literals were added too.
class MRAIDJavascriptCommandsTests: XCTestCase {
    
    func testMRAIDJavascriptCommandsWithParams() {
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.isEnabled(), "typeof mraid !== 'undefined'")
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onReady(), "mraid.onReady();")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onReadyExpanded(), "mraid.onReadyExpanded();")
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.nativeCallComplete(), "mraid.nativeCallComplete();");

        // onExposureChange
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onExposureChange(OXMViewExposure(exposureFactor: 1,
                                                                                   visibleRectangle: CGRect(x: 0, y: 0, width: 100, height: 100))),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": null}\");")
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onExposureChange(OXMViewExposure(exposureFactor: 1,
                                                                                   visibleRectangle: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                                                   occlusionRectangles: [CGRect(x: 70, y: 80, width: 30, height: 20),
                                                                                                         CGRect(x: 0, y: 0, width: 10, height: 10)])),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": [{\\\"x\\\": 70.0, \\\"y\\\": 80.0, \\\"width\\\": 30.0, \\\"height\\\": 20.0}, {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 10.0, \\\"height\\\": 10.0}]}\");")
        
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onExposureChange(.zero),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 0.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 0.0, \\\"height\\\": 0.0}, \\\"occlusionRectangles\\\": null}\");")

        // onSizeChange
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 0.0, height: 0.0)), "mraid.onSizeChange(0.0,0.0);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onSizeChange(CGSize(width: -1.1, height: -2.2)), "mraid.onSizeChange(-1.1,-2.2);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1, height: 2)), "mraid.onSizeChange(1.0,2.0);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1.1, height: 2.2)), "mraid.onSizeChange(1.1,2.2);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1.1111, height: 2.2222)), "mraid.onSizeChange(1.1111,2.2222);")

        // onStateChange
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onStateChange(.default), "mraid.onStateChange('default');");
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onStateChange(.expanded), "mraid.onStateChange('expanded');");
        
        // onAudioVolumeChange
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onAudioVolumeChange(nil), "mraid.onAudioVolumeChange(null);");
        XCTAssertEqual(OXMMRAIDJavascriptCommands.onAudioVolumeChange(NSNumber(value: 50.5)), "mraid.onAudioVolumeChange(50.5);");
        
        // updatePlacementType
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updatePlacementType(.inline), "mraid.placementType = 'inline';")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updatePlacementType(.interstitial), "mraid.placementType = 'interstitial';")

        // updateMaxSize
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 0.0, height: 0.0)), "mraid.setMaxSize(0.0,0.0);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1, height: 2)), "mraid.setMaxSize(1.0,2.0);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1.11, height: 2.22)), "mraid.setMaxSize(1.11,2.22);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 375, height: 667)), "mraid.setMaxSize(375.0,667.0);")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1024, height: 1366)), "mraid.setMaxSize(1024.0,1366.0);")

        // updateScreenSize
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 0.0, height: 0.0)) , "mraid.screenSize = {width:0.0,height:0.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1, height: 2)) , "mraid.screenSize = {width:1.0,height:2.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1.11, height: 2.22)) , "mraid.screenSize = {width:1.11,height:2.22};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 375, height: 667)) , "mraid.screenSize = {width:375.0,height:667.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1024, height: 1366)) , "mraid.screenSize = {width:1024.0,height:1366.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1024.0, height: 1366.0)) , "mraid.screenSize = {width:1024.0,height:1366.0};")

        // updateDefaultPosition
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 0, y: 0, width: 0, height: 0)), "mraid.defaultPosition = {x:0.0, y:0.0, width:0.0, height:0.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 1, y: 2, width: 3, height: 4)), "mraid.defaultPosition = {x:1.0, y:2.0, width:3.0, height:4.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 1.11, y: 2.22, width: 3.33, height: 4.44)), "mraid.defaultPosition = {x:1.11, y:2.22, width:3.33, height:4.44};")

        // updateCurrentPosition
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 0, y: 0, width: 0, height: 0)), "mraid.currentPosition = {x:0.0, y:0.0, width:0.0, height:0.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 1, y: 2, width: 3, height: 4)), "mraid.currentPosition = {x:1.0, y:2.0, width:3.0, height:4.0};")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 1.11, y: 2.22, width: 3.33, height: 4.44)), "mraid.currentPosition = {x:1.11, y:2.22, width:3.33, height:4.44};")
        
        // updateLocation
        var coordinate = CLLocationCoordinate2DMake(0, 0)
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateLocation(coordinate, accuracy: 0, timeStamp: 0),
                       "mraid.setLocation(0.0,0.0,0.0,0.0);")
        coordinate = CLLocationCoordinate2DMake(12.34, 56.78)
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateLocation(coordinate, accuracy: 1.0, timeStamp: 2.0),
                       "mraid.setLocation(12.34,56.78,1.0,2.0);")
        
        XCTAssertEqual(OXMMRAIDJavascriptCommands.getCurrentPosition(), "JSON.stringify(mraid.getCurrentPosition());")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.getOrientationProperties(), "JSON.stringify(mraid.getOrientationProperties());")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.getExpandProperties(), "JSON.stringify(mraid.getExpandProperties());")
        XCTAssertEqual(OXMMRAIDJavascriptCommands.getResizeProperties(), "JSON.stringify(mraid.getResizeProperties());")

        XCTAssertEqual(OXMMRAIDJavascriptCommands.onError("test message", action: .open), "mraid.onError('test message','open');")
        
        // currentAppOrientation
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateCurrentAppOrientation("portrait", locked: false),
                       "mraid.setCurrentAppOrientation('portrait', false);");
        XCTAssertEqual(OXMMRAIDJavascriptCommands.updateCurrentAppOrientation("landscape", locked: true),
                       "mraid.setCurrentAppOrientation('landscape', true);");
    }

    func test_updateSupportedFeatures() {
        let expectedFeatures: [String: Any] = [
            "sms": true,
            "storePicture": true,
            "inlineVideo": true,
            "calendar": true,
            "tel": true,
            "location": true,
            "vpaid": false,
        ]

        let features = OXMMRAIDJavascriptCommands.updateSupportedFeatures()
        let matches = regexMatch(features, pattern: "mraid.allSupports = (\\{.+\\});")
        let jsonString = matches.count == 2 ? matches[1] : ""
        if let actualFeatures = try? OXMFunctions.dictionaryFromJSONString(jsonString) {
            XCTAssertEqual(NSDictionary(dictionary: expectedFeatures), NSDictionary(dictionary: actualFeatures))
        } else {
            XCTFail("Supported features string did not contain a JSON substring")
        }
    }

    /**
     JavaScript `match` inspired function to perform a regex search on a string.

     If the string matches the regex, it will return an array containing the
     entire matched string as the first element, followed by any results
     captured in parentheses.

     If there were no matches, an empty array is returned.

     - parameters:
         - string: The string to search
         - pattern: The regex pattern to use in the search
    */
    func regexMatch(_ string: String, pattern: String) -> [String] {
        var results = [String]()

        let range = NSRange(location: 0, length: string.count)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: string, options: [], range: range) {
            for i in 0..<match.numberOfRanges {
                let matchedRange = match.range(at: i)
                let matchStart = string.index(string.startIndex, offsetBy: matchedRange.location)
                let matchEnd = string.index(matchStart, offsetBy: matchedRange.length)
                results.append(String(string[matchStart..<matchEnd]))
            }

        }

        return results
    }

}

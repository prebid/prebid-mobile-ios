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

// This test case was created during porting SDK to Objective-C.
// The purpose of these tests is to be sure that methods' parameters are converted to the output strings properly.
// Just in case tests for string literals were added too.
class MRAIDJavascriptCommandsTests: XCTestCase {
    
    func testMRAIDJavascriptCommandsWithParams() {
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.isEnabled(), "typeof mraid !== 'undefined'")
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onReady(), "mraid.onReady();")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onReadyExpanded(), "mraid.onReadyExpanded();")
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.nativeCallComplete(), "mraid.nativeCallComplete();");
        
        // onExposureChange
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onExposureChange(PBMViewExposure(exposureFactor: 1,
                                                                                   visibleRectangle: CGRect(x: 0, y: 0, width: 100, height: 100))),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": null}\");")
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onExposureChange(PBMViewExposure(exposureFactor: 1,
                                                                                   visibleRectangle: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                                                   occlusionRectangles: [CGRect(x: 70, y: 80, width: 30, height: 20), CGRect(x: 0, y: 0, width: 10, height: 10)])),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": [{\\\"x\\\": 70.0, \\\"y\\\": 80.0, \\\"width\\\": 30.0, \\\"height\\\": 20.0}, {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 10.0, \\\"height\\\": 10.0}]}\");")
        
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onExposureChange(.zero),
                       "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 0.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 0.0, \\\"height\\\": 0.0}, \\\"occlusionRectangles\\\": null}\");")
        
        // onSizeChange
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 0.0, height: 0.0)), "mraid.onSizeChange(0.0,0.0);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onSizeChange(CGSize(width: -1.1, height: -2.2)), "mraid.onSizeChange(-1.1,-2.2);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1, height: 2)), "mraid.onSizeChange(1.0,2.0);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1.1, height: 2.2)), "mraid.onSizeChange(1.1,2.2);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onSizeChange(CGSize(width: 1.1111, height: 2.2222)), "mraid.onSizeChange(1.1111,2.2222);")
        
        // onStateChange
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onStateChange(.default), "mraid.onStateChange('default');");
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onStateChange(.expanded), "mraid.onStateChange('expanded');");
        
        // onAudioVolumeChange
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onAudioVolumeChange(nil), "mraid.onAudioVolumeChange(null);");
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onAudioVolumeChange(NSNumber(value: 50.5)), "mraid.onAudioVolumeChange(50.5);");
        
        // updatePlacementType
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updatePlacementType(.inline), "mraid.placementType = 'inline';")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updatePlacementType(.interstitial), "mraid.placementType = 'interstitial';")
        
        // updateMaxSize
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 0.0, height: 0.0)), "mraid.setMaxSize(0.0,0.0);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1, height: 2)), "mraid.setMaxSize(1.0,2.0);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1.11, height: 2.22)), "mraid.setMaxSize(1.11,2.22);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 375, height: 667)), "mraid.setMaxSize(375.0,667.0);")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateMaxSize(CGSize(width: 1024, height: 1366)), "mraid.setMaxSize(1024.0,1366.0);")
        
        // updateScreenSize
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 0.0, height: 0.0)) , "mraid.screenSize = {width:0.0,height:0.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1, height: 2)) , "mraid.screenSize = {width:1.0,height:2.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1.11, height: 2.22)) , "mraid.screenSize = {width:1.11,height:2.22};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 375, height: 667)) , "mraid.screenSize = {width:375.0,height:667.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1024, height: 1366)) , "mraid.screenSize = {width:1024.0,height:1366.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateScreenSize(CGSize(width: 1024.0, height: 1366.0)) , "mraid.screenSize = {width:1024.0,height:1366.0};")
        
        // updateDefaultPosition
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 0, y: 0, width: 0, height: 0)), "mraid.defaultPosition = {x:0.0, y:0.0, width:0.0, height:0.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 1, y: 2, width: 3, height: 4)), "mraid.defaultPosition = {x:1.0, y:2.0, width:3.0, height:4.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: 1.11, y: 2.22, width: 3.33, height: 4.44)), "mraid.defaultPosition = {x:1.11, y:2.22, width:3.33, height:4.44};")
        
        // updateCurrentPosition
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 0, y: 0, width: 0, height: 0)), "mraid.currentPosition = {x:0.0, y:0.0, width:0.0, height:0.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 1, y: 2, width: 3, height: 4)), "mraid.currentPosition = {x:1.0, y:2.0, width:3.0, height:4.0};")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: 1.11, y: 2.22, width: 3.33, height: 4.44)), "mraid.currentPosition = {x:1.11, y:2.22, width:3.33, height:4.44};")
        
        // updateLocation
        var coordinate = CLLocationCoordinate2DMake(0, 0)
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateLocation(coordinate, accuracy: 0, timeStamp: 0),
                       "mraid.setLocation(0.0,0.0,0.0,0.0);")
        coordinate = CLLocationCoordinate2DMake(12.34, 56.78)
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateLocation(coordinate, accuracy: 1.0, timeStamp: 2.0),
                       "mraid.setLocation(12.34,56.78,1.0,2.0);")
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.getCurrentPosition(), "JSON.stringify(mraid.getCurrentPosition());")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.getOrientationProperties(), "JSON.stringify(mraid.getOrientationProperties());")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.getExpandProperties(), "JSON.stringify(mraid.getExpandProperties());")
        XCTAssertEqual(PBMMRAIDJavascriptCommands.getResizeProperties(), "JSON.stringify(mraid.getResizeProperties());")
        
        XCTAssertEqual(PBMMRAIDJavascriptCommands.onError("test message", action: .open), "mraid.onError('test message','open');")
        
        // currentAppOrientation
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateCurrentAppOrientation("portrait", locked: false),
                       "mraid.setCurrentAppOrientation('portrait', false);");
        XCTAssertEqual(PBMMRAIDJavascriptCommands.updateCurrentAppOrientation("landscape", locked: true),
                       "mraid.setCurrentAppOrientation('landscape', true);");
    }
    
    func test_updateSupportedFeatures() {
        let expectedFeatures: [String: Any] = [
            "sms": true,
            "storePicture": false,
            "inlineVideo": true,
            "calendar": false,
            "tel": true,
            "location": true,
            "vpaid": false,
        ]
        
        let features = PBMMRAIDJavascriptCommands.updateSupportedFeatures()
        let matches = regexMatch(features, pattern: "mraid.allSupports = (\\{.+\\});")
        let jsonString = matches.count == 2 ? matches[1] : ""
        if let actualFeatures = try? PBMFunctions.dictionaryFromJSONString(jsonString) {
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

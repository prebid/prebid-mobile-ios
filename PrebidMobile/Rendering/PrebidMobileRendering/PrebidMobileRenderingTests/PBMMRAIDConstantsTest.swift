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

class PBMMRAIDConstantsTest: XCTestCase {
    
    func testPBMMRAIDParseKeys() {
        XCTAssertEqual(PBMMRAIDParseKeys.X                  , "x")
        XCTAssertEqual(PBMMRAIDParseKeys.Y                  , "y")
        XCTAssertEqual(PBMMRAIDParseKeys.WIDTH              , "width")
        XCTAssertEqual(PBMMRAIDParseKeys.HEIGHT             , "height")
        XCTAssertEqual(PBMMRAIDParseKeys.X_OFFSET           , "offsetX")
        XCTAssertEqual(PBMMRAIDParseKeys.Y_OFFSET           , "offsetY")
        XCTAssertEqual(PBMMRAIDParseKeys.ALLOW_OFFSCREEN    , "allowOffscreen")
        XCTAssertEqual(PBMMRAIDParseKeys.FORCE_ORIENTATION  , "forceOrientation")
    }
    
    func testPBMMRAIDValues() {
        XCTAssertEqual(PBMMRAIDValues.LANDSCAPE, "landscape")
        XCTAssertEqual(PBMMRAIDValues.PORTRAIT, "portrait")
    }
    
    func testPBMMRAIDCloseButtonPosition() {
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.BOTTOM_CENTER, "bottom-center")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.BOTTOM_LEFT  , "bottom-left")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.BOTTOM_RIGHT , "bottom-right")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.CENTER       , "center")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.TOP_CENTER   , "top-center")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.TOP_LEFT     , "top-left")
        XCTAssertEqual(PBMMRAIDCloseButtonPosition.TOP_RIGHT    , "top-right")
    }
    
    func testPBMMRAIDCloseButtonSize() {
        XCTAssertEqual(PBMMRAIDCloseButtonSize.WIDTH, 50)
        XCTAssertEqual(PBMMRAIDCloseButtonSize.HEIGHT, 50)
    }
    
    func testPBMMRAIDConstants() {
        XCTAssertEqual(PBMMRAIDConstants.mraidURLScheme, "mraid:");
        
        let allCasses = PBMMRAIDConstants.allCases
        let expectedCasses: [String] = {
            let actions: [PBMMRAIDAction] = [
                .open,
                .expand,
                .resize,
                .close,
                .storePicture,
                .createCalendarEvent,
                .playVideo,
                .log,
                .onOrientationPropertiesChanged,
                .unload,
            ]
            return actions.map { $0.rawValue }
        }()
        
        XCTAssertEqual(allCasses, expectedCasses)
    }
}

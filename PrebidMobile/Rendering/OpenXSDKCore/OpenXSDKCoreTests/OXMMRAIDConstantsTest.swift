//
//  OXMMRAIDConstants.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMMRAIDConstantsTest: XCTestCase {
    
    func testOXMMRAIDParseKeys() {
        XCTAssertEqual(OXMMRAIDParseKeys.X                  , "x")
        XCTAssertEqual(OXMMRAIDParseKeys.Y                  , "y")
        XCTAssertEqual(OXMMRAIDParseKeys.WIDTH              , "width")
        XCTAssertEqual(OXMMRAIDParseKeys.HEIGHT             , "height")
        XCTAssertEqual(OXMMRAIDParseKeys.X_OFFSET           , "offsetX")
        XCTAssertEqual(OXMMRAIDParseKeys.Y_OFFSET           , "offsetY")
        XCTAssertEqual(OXMMRAIDParseKeys.ALLOW_OFFSCREEN    , "allowOffscreen")
        XCTAssertEqual(OXMMRAIDParseKeys.FORCE_ORIENTATION  , "forceOrientation")
    }
    
    func testOXMMRAIDValues() {
        XCTAssertEqual(OXMMRAIDValues.LANDSCAPE, "landscape")
        XCTAssertEqual(OXMMRAIDValues.PORTRAIT, "portrait")
    }
    
    func testOXMMRAIDCloseButtonPosition() {
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.BOTTOM_CENTER, "bottom-center")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.BOTTOM_LEFT  , "bottom-left")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.BOTTOM_RIGHT , "bottom-right")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.CENTER       , "center")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.TOP_CENTER   , "top-center")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.TOP_LEFT     , "top-left")
        XCTAssertEqual(OXMMRAIDCloseButtonPosition.TOP_RIGHT    , "top-right")
    }
    
    func testOXMMRAIDCloseButtonSize() {
        XCTAssertEqual(OXMMRAIDCloseButtonSize.WIDTH, 50)
        XCTAssertEqual(OXMMRAIDCloseButtonSize.HEIGHT, 50)
    }
    
    func testOXMMRAIDConstants() {
        XCTAssertEqual(OXMMRAIDConstants.mraidURLScheme, "mraid:");
        
        let allCasses = OXMMRAIDConstants.allCases
        let expectedCasses: [String] = {
            let actions: [OXMMRAIDAction] = [
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

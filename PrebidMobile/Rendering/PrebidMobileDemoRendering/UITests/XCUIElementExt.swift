//
//  XCTestCaseExt.swift
//  OpenXDemoAppSwiftUITests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

//  sourced from
//  https://stackoverflow.com/questions/41353959/xctest-how-to-tap-on-url-link-inside-uitextview

import XCTest

extension XCUIElement {
    
    public func tapFrameCenter(withNumberOfTaps numberOfTaps: Int = 1) {
        let frameCenterCoordinate = self.frameCenter()
        for _ in 0..<numberOfTaps {
            frameCenterCoordinate.tap()
        }
    }

    func frameCenter() -> XCUICoordinate {
        let centerX = self.frame.midX
        let centerY = self.frame.midY

        let normalizedCoordinate = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let frameCenterCoordinate = normalizedCoordinate.withOffset(CGVector(dx: centerX, dy: centerY))

        return frameCenterCoordinate
    }
    
    var isOn: Bool {
        return (value as? String).map { $0 == "1" } ?? false
    }
}

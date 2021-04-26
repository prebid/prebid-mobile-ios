//
//  PBMTouchDownRecognizerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

import Foundation
import XCTest
@testable import PrebidMobileRendering

class PBMTouchDownRecognizerTests : XCTestCase {
    
    func testBasic() {
        //Note: GestureRecognizers are notoriously difficult to test.
        //They are tightly coupled to the views they are attached to
        //and intercept touch events from them. Unless they are "real" events they don't call their completion selector on their
        //target and don't reset back to .Possible (their default state) on the next run of the run loop.
        //For security purposes, these touch events can't be instantiated without hitting a private API that changes rapidly
        //between release of iOS. For more information, see:
        //http://blog.lazerwalker.com/objective-c/code/2013/10/16/faking-touch-events-on-ios-for-fun-and-profit.html
        
        //Should start as Possible
        let pbmTouchDownRecognizer = PBMTouchDownRecognizer()
        PBMAssertEq(pbmTouchDownRecognizer.state, UIGestureRecognizer.State.possible)
        
        //If you touch down onto the view it should immediately count as ended.
        //This will not fire the associated selector, though.
        let touches = Set<UITouch>([UITouch()])
        pbmTouchDownRecognizer.touchesBegan(touches, with: UIEvent())
        PBMAssertEq(pbmTouchDownRecognizer.state.rawValue, UIGestureRecognizer.State.ended.rawValue)
    }
}

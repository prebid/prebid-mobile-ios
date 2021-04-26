//
//  PBMTouchForwardingViewTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMTouchForwardingViewTest: XCTestCase {
    
    let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    let contentRect = CGRect(x: 20, y: 20, width: 50, height: 50)
    
    func testInit() {
        
        let touchForwardingView = PBMTouchForwardingView()
        XCTAssertNotNil(touchForwardingView)
        XCTAssertNil(touchForwardingView.passThroughViews)
        
        touchForwardingView.passThroughViews = [UIView()]
        XCTAssertNotNil(touchForwardingView.passThroughViews)
    }
    
    func testHitContentView() {
        
        let hitPoint = CGPoint(x: 30, y: 30)

        let touchForwardingView = PBMTouchForwardingView(frame: rect)
        XCTAssertNotNil(touchForwardingView)
        XCTAssertNil(touchForwardingView.passThroughViews)
        
        let contentView = UIView(frame: contentRect)
        touchForwardingView.passThroughViews = [contentView]
        XCTAssertNotNil(touchForwardingView.passThroughViews)

        // Point intersect area of passThroughViews
        let touchedView = touchForwardingView.hitTest(hitPoint, with: nil)
        XCTAssertTrue(touchedView == contentView)
    }
    
    func testHitTouchForwardingView() {
        
        let hitPoint = CGPoint(x: 10, y: 10)

        let touchForwardingView = PBMTouchForwardingView(frame: rect)
        XCTAssertNotNil(touchForwardingView)
        XCTAssertNil(touchForwardingView.passThroughViews)
        
        let contentView = UIView(frame: contentRect)
        touchForwardingView.passThroughViews = [contentView]
        XCTAssertNotNil(touchForwardingView.passThroughViews)
        
        // Point inside PBMTouchForwardingView
        let pointInside = touchForwardingView.point(inside: hitPoint, with: nil)
        XCTAssertTrue(pointInside)
        
        // Point does not intersect area of passThroughViews
        let touchedView = touchForwardingView.hitTest(hitPoint, with: nil)
        XCTAssertNil(touchedView)
    }
}

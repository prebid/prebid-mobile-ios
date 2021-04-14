//
//  OXMCreativeViewabilityTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

class OXMCreativeViewabilityTrackerTest: XCTestCase {
    
    var expectationOnExposureChange: XCTestExpectation!
    
    override func tearDown() {
        self.expectationOnExposureChange = nil
    }
    
    func testCheckExposure() {
        
        let parentWindow = UIWindow()
        let parentView = UIView()
        let view = UIView()
        
        parentWindow.isHidden = false

        parentWindow.frame  = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        parentView.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        view.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)

        parentView.addSubview(view)
        parentWindow.addSubview(parentView)
        
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        
        let viewabilityTracker = OXMCreativeViewabilityTracker(view: view, pollingTimeInterval: 10, onExposureChange:{ _, _ in
            self.expectationOnExposureChange.fulfill()
        });
        
        viewabilityTracker.checkExposure(withForce: false)
        self.waitForExpectations(timeout: 1)
        
        // exposure didn't change and isForce is false - onExposureChange should not be called
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        self.expectationOnExposureChange.isInverted = true
        viewabilityTracker.checkExposure(withForce: false)
        self.waitForExpectations(timeout: 1)
        
        // exposure didn't change BUT isForce is true - onExposureChange should be called
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        viewabilityTracker.checkExposure(withForce: true)
        self.waitForExpectations(timeout: 1)
        
    }
}

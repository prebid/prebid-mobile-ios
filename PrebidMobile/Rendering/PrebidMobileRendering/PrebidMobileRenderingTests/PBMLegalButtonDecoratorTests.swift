//
//  PBMLegalButtonDecoratorTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMLegalButtonDecoratorTests: XCTestCase {
    
    let buttonDecorator = PBMLegalButtonDecorator(position: .topRight)

    func testClickthroughBrowserView() {
        XCTAssertNotNil(buttonDecorator)
        let clickthroughBrowserView = buttonDecorator.clickthroughBrowserView()
        XCTAssertNotNil(clickthroughBrowserView)
        
        XCTAssertEqual(clickthroughBrowserView?.webView?.url?.absoluteString,
                       PBMPrivacyPolicyUrlString)
    }
    
    func testButtonTappedAction() {
        XCTAssertNotNil(buttonDecorator)
        
        let expectation = self.expectation(description: "buttonTappedAction")
        buttonDecorator.buttonTouchUpInsideBlock = {
            expectation.fulfill()
        }
        
        // Setup superview
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        buttonDecorator.addButton(to: view, display: view)
        buttonDecorator.updateButtonConstraints()
        buttonDecorator.bringButtonToFront()
        
        var imgSize = buttonDecorator.button.currentImage?.size
        XCTAssertEqual(imgSize?.width, 20.0, "Button image should be collapsed")
        XCTAssertEqual(imgSize?.height, 20.0, "Wrong button image height: \(String(describing: imgSize?.height))")
        
        // First tap make button Expanded
        buttonDecorator.buttonTappedAction()

        imgSize = buttonDecorator.button.currentImage?.size
        XCTAssertEqual(imgSize?.width, 88.0, "Button image should be expanded")
        XCTAssertEqual(imgSize?.height, 20.0, "Wrong button image height: \(String(describing: imgSize?.height))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
            // Second tap make button Minimized and execute block
            self.buttonDecorator.buttonTappedAction()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testGetButtonConstraintConstant() {
        XCTAssertNotNil(buttonDecorator)
        XCTAssertEqual(buttonDecorator.getButtonConstraintConstant(), 0)
    }

    func testSetButtonPosition() {
        XCTAssertEqual(buttonDecorator.buttonPosition.rawValue, PBMPosition.topRight.rawValue,
                  "Wrong position, got \(String(describing: buttonDecorator.buttonPosition.rawValue))")
        
        buttonDecorator.buttonPosition = PBMPosition.bottomRight
        XCTAssertEqual(buttonDecorator.buttonPosition.rawValue, PBMPosition.bottomRight.rawValue,
                  "Wrong position, got \(String(describing: buttonDecorator.buttonPosition.rawValue))")
    }
}

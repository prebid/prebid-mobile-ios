//
//  PBMAdViewButtonDecoratorTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMAdViewButtonDecoratorTests: XCTestCase {
    
    var buttonDecorator: PBMAdViewButtonDecorator!
    
    override func setUp() {
        super.setUp()
        buttonDecorator = PBMAdViewButtonDecorator()
    }
    
    override func tearDown() {
        buttonDecorator = nil
        super.tearDown()
    }
    
    func testGetButtonConstraintConstant() {
        XCTAssertNotNil(buttonDecorator)
        XCTAssertEqual(buttonDecorator.getButtonConstraintConstant(), 10)
    }
    
    func testButtonTappedAction() {
        XCTAssertNotNil(buttonDecorator)
        let expectation = self.expectation(description: "buttonTappedAction")
        buttonDecorator.buttonTouchUpInsideBlock = {
            expectation.fulfill()
        }

        buttonDecorator.buttonTappedAction()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetButtonSize() {
        //There is no image by default
        XCTAssertNil(buttonDecorator.button.currentImage)
        
        var buttonSize = buttonDecorator.getButtonSize()
        
        XCTAssertEqual(buttonSize, CGSize(width:10, height:10))
        
        //The button size should be equal to the image size
        let image = UIImage(named: "adchoices-expanded-bottom-right",
                            in: Bundle(for: type(of: self)), compatibleWith: nil)
        buttonDecorator.setImage(image!)
        buttonSize = buttonDecorator.getButtonSize()
        XCTAssertEqual(buttonSize, image?.size)
        XCTAssertEqual(buttonDecorator.button.currentImage, image)
    }
    
    func testAddButtonToView() {

        XCTAssertEqual(buttonDecorator.button.allTargets.count, 0)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        buttonDecorator.addButton(to: view, display: view)
        XCTAssertEqual(buttonDecorator.button.allTargets.count, 1)

        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.addSubview(subView)
        buttonDecorator.bringButtonToFront()
        XCTAssertEqual(view.subviews.count, 2)
        XCTAssertEqual(buttonDecorator.button, view.subviews.last)
        
        buttonDecorator.sendSubviewToBack()
        XCTAssertEqual(buttonDecorator.button, view.subviews.first)
        
        buttonDecorator.removeButtonFromSuperview()
        XCTAssertEqual(view.subviews.count, 1)
    }
}

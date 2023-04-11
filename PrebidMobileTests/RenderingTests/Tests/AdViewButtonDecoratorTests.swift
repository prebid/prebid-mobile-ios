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

class AdViewButtonDecoratorTests: XCTestCase {
    
    var buttonDecorator: AdViewButtonDecorator!
    
    override func setUp() {
        super.setUp()
        buttonDecorator = AdViewButtonDecorator()
    }
    
    override func tearDown() {
        buttonDecorator = nil
        super.tearDown()
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
        let constant = 0.25
        XCTAssertNil(buttonDecorator.button.currentImage)
        buttonDecorator.buttonArea = constant
        let sizeValue: CGFloat = UIApplication.shared.statusBarOrientation.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height * constant
        let buttonSize = CGSize(width: sizeValue, height: sizeValue)
        let resultButtonSize = buttonDecorator.getButtonSize()
        
        XCTAssertEqual(resultButtonSize, buttonSize)
        
        let image = PrebidImagesRepository.closeButton.base64DecodedImage
        buttonDecorator.setImage(image!)
        XCTAssertEqual(buttonDecorator.button.currentImage?.pngData(), image?.pngData())
    }
    
    func testGetButtonConstraintConstant() {
        let constant = 0.1
        XCTAssertNil(buttonDecorator.button.currentImage)
        buttonDecorator.buttonArea = constant
        
        let screenWidth = UIApplication.shared.statusBarOrientation.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        let expectedConstraintConstant = (screenWidth * constant) / 2
        let buttonConstraint = buttonDecorator.getButtonConstraintConstant()
        XCTAssertTrue(expectedConstraintConstant == buttonConstraint || buttonConstraint == PBMConstants.buttonConstraintConstant.doubleValue)
    }
    
    func testAddButtonToView() {
        
        XCTAssertEqual(buttonDecorator.button.allTargets.count, 0)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        buttonDecorator.addButton(to: view, displayView: view)
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
    
    func testDefaultButtonPosition() {
        XCTAssertTrue(buttonDecorator.buttonPosition == .topRight)
    }
}

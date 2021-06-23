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
        let image = UIImage(named: "PBM_closeButton",
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
